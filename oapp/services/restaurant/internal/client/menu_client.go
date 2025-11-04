package client

import (
	"encoding/json"
	"fmt"
	"net/http"
	"time"
)

// MenuServiceClient handles communication with Menu Service
type MenuServiceClient struct {
	baseURL    string
	httpClient *http.Client
}

// LocationMenuCheck represents the response from has-menus endpoint
type LocationMenuCheck struct {
	HasMenus   bool `json:"has_menus"`
	MenusCount int  `json:"menus_count"`
}

// NewMenuServiceClient creates a new Menu Service client
func NewMenuServiceClient(baseURL string) *MenuServiceClient {
	return &MenuServiceClient{
		baseURL: baseURL,
		httpClient: &http.Client{
			Timeout: 10 * time.Second,
		},
	}
}

// CheckLocationHasMenus checks if a location has any menus
func (c *MenuServiceClient) CheckLocationHasMenus(locationID string) (*LocationMenuCheck, error) {
	url := fmt.Sprintf("%s/internal/locations/%s/has-menus", c.baseURL, locationID)

	resp, err := c.httpClient.Get(url)
	if err != nil {
		return nil, fmt.Errorf("failed to call menu service: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("menu service returned status %d", resp.StatusCode)
	}

	var result LocationMenuCheck
	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		return nil, fmt.Errorf("failed to decode response: %w", err)
	}

	return &result, nil
}
