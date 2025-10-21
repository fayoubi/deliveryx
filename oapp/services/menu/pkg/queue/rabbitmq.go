package queue

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"time"

	amqp "github.com/rabbitmq/amqp091-go"
)

type RabbitMQClient struct {
	conn    *amqp.Connection
	channel *amqp.Channel
}

// MenuSubmittedEvent represents the event published when a menu is submitted
type MenuSubmittedEvent struct {
	MenuID      string    `json:"menu_id"`
	LocationID  string    `json:"location_id"`
	SubmittedAt time.Time `json:"submitted_at"`
}

// NewRabbitMQClient creates a new RabbitMQ client
func NewRabbitMQClient(url string) (*RabbitMQClient, error) {
	conn, err := amqp.Dial(url)
	if err != nil {
		return nil, fmt.Errorf("failed to connect to RabbitMQ: %w", err)
	}

	channel, err := conn.Channel()
	if err != nil {
		conn.Close()
		return nil, fmt.Errorf("failed to open channel: %w", err)
	}

	// Declare the menu-submitted queue with durability
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

	log.Println("✅ Connected to RabbitMQ and queue declared")

	return &RabbitMQClient{
		conn:    conn,
		channel: channel,
	}, nil
}

// PublishMenuSubmitted publishes a menu-submitted event to the queue
func (c *RabbitMQClient) PublishMenuSubmitted(ctx context.Context, event MenuSubmittedEvent) error {
	body, err := json.Marshal(event)
	if err != nil {
		return fmt.Errorf("failed to marshal event: %w", err)
	}

	err = c.channel.PublishWithContext(
		ctx,
		"",               // exchange
		"menu-submitted", // routing key (queue name)
		false,            // mandatory
		false,            // immediate
		amqp.Publishing{
			DeliveryMode: amqp.Persistent,
			ContentType:  "application/json",
			Body:         body,
			Timestamp:    time.Now(),
		},
	)
	if err != nil {
		return fmt.Errorf("failed to publish message: %w", err)
	}

	log.Printf("📤 Published menu-submitted event for menu_id: %s", event.MenuID)
	return nil
}

// Close closes the RabbitMQ connection
func (c *RabbitMQClient) Close() error {
	if err := c.channel.Close(); err != nil {
		return err
	}
	return c.conn.Close()
}
