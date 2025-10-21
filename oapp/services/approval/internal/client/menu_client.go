package client

import (
	"bytes"
	"encoding/json"
	"fmt"
	"net/http"
	"time"
)

// MenuClient handles communication with Menu Service
type MenuClient struct {
	baseURL    string
	httpClient *http.Client
}

// NewMenuClient creates a new Menu Service client
func NewMenuClient(baseURL string) *MenuClient {
	return &MenuClient{
		baseURL: baseURL,
		httpClient: &http.Client{
			Timeout: 10 * time.Second,
		},
	}
}

// UpdateMenuStatus updates the menu status in Menu Service
func (c *MenuClient) UpdateMenuStatus(menuID, status string, rejectionReason *string) error {
	url := fmt.Sprintf("%s/internal/menus/%s/status", c.baseURL, menuID)

	payload := map[string]interface{}{
		"status": status,
	}
	if rejectionReason != nil {
		payload["rejection_reason"] = *rejectionReason
	}

	jsonData, err := json.Marshal(payload)
	if err != nil {
		return fmt.Errorf("failed to marshal request: %w", err)
	}

	req, err := http.NewRequest("PUT", url, bytes.NewBuffer(jsonData))
	if err != nil {
		return fmt.Errorf("failed to create request: %w", err)
	}
	req.Header.Set("Content-Type", "application/json")

	resp, err := c.httpClient.Do(req)
	if err != nil {
		return fmt.Errorf("failed to update menu status: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return fmt.Errorf("menu service returned status %d", resp.StatusCode)
	}

	return nil
}
