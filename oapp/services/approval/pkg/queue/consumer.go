package queue

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"time"

	amqp "github.com/rabbitmq/amqp091-go"
)

type Consumer struct {
	conn    *amqp.Connection
	channel *amqp.Channel
}

// MenuSubmittedEvent represents the event consumed from the queue
type MenuSubmittedEvent struct {
	MenuID      string    `json:"menu_id"`
	LocationID  string    `json:"location_id"`
	SubmittedAt time.Time `json:"submitted_at"`
}

// MenuSubmittedHandler is a function that processes menu-submitted events
type MenuSubmittedHandler func(ctx context.Context, event MenuSubmittedEvent) error

// NewConsumer creates a new RabbitMQ consumer
func NewConsumer(url string) (*Consumer, error) {
	conn, err := amqp.Dial(url)
	if err != nil {
		return nil, fmt.Errorf("failed to connect to RabbitMQ: %w", err)
	}

	channel, err := conn.Channel()
	if err != nil {
		conn.Close()
		return nil, fmt.Errorf("failed to open channel: %w", err)
	}

	// Ensure the queue exists
	_, err = channel.QueueDeclare(
		"menu-submitted", // name
		true,             // durable
		false,            // delete when unused
		false,            // exclusive
		false,            // no-wait
		amqp.Table{
			"x-dead-letter-exchange": "dlx",
		},
	)
	if err != nil {
		channel.Close()
		conn.Close()
		return nil, fmt.Errorf("failed to declare queue: %w", err)
	}

	// Set QoS - prefetch 1 message at a time
	err = channel.Qos(
		1,     // prefetch count
		0,     // prefetch size
		false, // global
	)
	if err != nil {
		channel.Close()
		conn.Close()
		return nil, fmt.Errorf("failed to set QoS: %w", err)
	}

	log.Println("✅ Consumer connected to RabbitMQ")

	return &Consumer{
		conn:    conn,
		channel: channel,
	}, nil
}

// ConsumeMenuSubmitted starts consuming menu-submitted events
func (c *Consumer) ConsumeMenuSubmitted(ctx context.Context, handler MenuSubmittedHandler) error {
	msgs, err := c.channel.Consume(
		"menu-submitted",           // queue
		"approval-service-consumer", // consumer tag
		false,                       // auto-ack
		false,                       // exclusive
		false,                       // no-local
		false,                       // no-wait
		nil,                         // args
	)
	if err != nil {
		return fmt.Errorf("failed to register consumer: %w", err)
	}

	log.Println("📥 Started consuming menu-submitted events...")

	for {
		select {
		case <-ctx.Done():
			log.Println("🛑 Stopping consumer...")
			return nil
		case msg, ok := <-msgs:
			if !ok {
				return fmt.Errorf("message channel closed")
			}

			// Parse the event
			var event MenuSubmittedEvent
			if err := json.Unmarshal(msg.Body, &event); err != nil {
				log.Printf("❌ Failed to unmarshal event: %v", err)
				// Reject and don't requeue - malformed messages go to DLQ
				msg.Nack(false, false)
				continue
			}

			log.Printf("📨 Received menu-submitted event for menu_id: %s", event.MenuID)

			// Process the event
			processCtx, cancel := context.WithTimeout(ctx, 30*time.Second)
			err := handler(processCtx, event)
			cancel()

			if err != nil {
				log.Printf("❌ Failed to process event for menu_id %s: %v", event.MenuID, err)
				// Reject and requeue - let it retry
				msg.Nack(false, true)
			} else {
				log.Printf("✅ Successfully processed event for menu_id: %s", event.MenuID)
				// Acknowledge successful processing
				msg.Ack(false)
			}
		}
	}
}

// Close closes the RabbitMQ connection
func (c *Consumer) Close() error {
	if err := c.channel.Close(); err != nil {
		return err
	}
	return c.conn.Close()
}
