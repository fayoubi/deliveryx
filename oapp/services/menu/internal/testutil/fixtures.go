package testutil

import (
	"time"

	"github.com/deliveryx/menu-service/internal/models"
	"github.com/google/uuid"
)

// TestFixtures provides test data for menu service tests
type TestFixtures struct {
	MenuID         string
	LocationID     string
	ProductID1     string
	ProductID2     string
	CollectionID   string
	AttributeID1   string
	AttributeID2   string
	AttributeGroup string
}

// NewTestFixtures creates a new set of test fixtures with UUIDs
func NewTestFixtures() *TestFixtures {
	return &TestFixtures{
		MenuID:         uuid.New().String(),
		LocationID:     uuid.New().String(),
		ProductID1:     uuid.New().String(),
		ProductID2:     uuid.New().String(),
		CollectionID:   uuid.New().String(),
		AttributeID1:   uuid.New().String(),
		AttributeID2:   uuid.New().String(),
		AttributeGroup: uuid.New().String(),
	}
}

// CreateTestMenu creates a test menu model
func (f *TestFixtures) CreateTestMenu(status string) *models.Menu {
	now := time.Now()
	menu := &models.Menu{
		MenuID:     f.MenuID,
		LocationID: f.LocationID,
		Status:     status,
		CreatedAt:  now,
		UpdatedAt:  now,
	}

	if status == "pending_review" || status == "approved" || status == "rejected" {
		menu.SubmittedAt = &now
	}

	if status == "approved" || status == "rejected" {
		menu.ReviewedAt = &now
	}

	if status == "rejected" {
		reason := "Test rejection reason"
		menu.RejectionReason = &reason
	}

	return menu
}

// CreateTestProduct creates a test product model
func (f *TestFixtures) CreateTestProduct(name string, price float64) *models.Product {
	description := "Test product description"
	imageURL := "https://example.com/image.jpg"
	return &models.Product{
		ProductID:   f.ProductID1,
		LocationID:  f.LocationID,
		Name:        name,
		Description: &description,
		Price:       price,
		Category:    StringPtr("Test Category"),
		ImageURL:    &imageURL,
		IsAvailable: true,
		CreatedAt:   time.Now(),
		UpdatedAt:   time.Now(),
	}
}

// CreateTestCollection creates a test collection model
func (f *TestFixtures) CreateTestCollection(name string, position int) *models.Collection {
	imageURL := "https://example.com/collection.jpg"
	return &models.Collection{
		CollectionID: f.CollectionID,
		MenuID:       f.MenuID,
		Name:         name,
		Position:     position,
		ImageURL:     &imageURL,
		CreatedAt:    time.Now(),
		UpdatedAt:    time.Now(),
	}
}

// CreateTestAttributeGroup creates a test attribute group model
func (f *TestFixtures) CreateTestAttributeGroup() *models.AttributeGroup {
	return &models.AttributeGroup{
		ID:            f.AttributeGroup,
		Name:          "Test Size",
		MinSelections: 1,
		MaxSelections: 1,
	}
}

// CreateTestAttribute creates a test attribute model
func (f *TestFixtures) CreateTestAttribute(name string, priceImpact float64) *models.Attribute {
	return &models.Attribute{
		ID:               f.AttributeID1,
		AttributeGroupID: f.AttributeGroup,
		Name:             name,
		PriceImpact:      priceImpact,
		IsDefault:        false,
	}
}

// CreateCompleteMenuResponse creates a test complete menu response
func (f *TestFixtures) CreateCompleteMenuResponse() *models.CompleteMenuResponse {
	return &models.CompleteMenuResponse{
		Attributes: []models.MenuAttribute{
			{
				ID:                f.AttributeID1,
				Name:              "Small",
				SelectedByDefault: false,
				PriceImpact:       0,
				Available:         true,
			},
			{
				ID:                f.AttributeID2,
				Name:              "Large",
				SelectedByDefault: true,
				PriceImpact:       2.5,
				Available:         true,
			},
		},
		AttributeGroups: []models.MenuAttributeGroup{
			{
				ID:                f.AttributeGroup,
				Name:              "Size",
				Min:               1,
				Max:               1,
				Collapse:          false,
				MultipleSelection: false,
				Attributes:        []string{f.AttributeID1, f.AttributeID2},
			},
		},
		Products: []models.MenuProductItem{
			{
				ID:               f.ProductID1,
				Name:             "Test Pizza",
				Price:            12.99,
				ImageURL:         StringPtr("https://example.com/pizza.jpg"),
				Description:      StringPtr("Delicious test pizza"),
				AttributesGroups: []string{f.AttributeGroup},
				Available:        true,
			},
		},
		Collections: []models.MenuCollection{
			{
				Name:     "Main Dishes",
				Position: 1,
				ImageURL: StringPtr("https://example.com/collection.jpg"),
				Sections: []models.MenuSection{
					{
						Name:     "Main Dishes",
						Position: 0,
						Products: []string{f.ProductID1},
					},
				},
			},
		},
		Supercollections: []interface{}{},
		Packs:            []interface{}{},
	}
}

// StringPtr returns a pointer to a string
func StringPtr(s string) *string {
	return &s
}

// Float64Ptr returns a pointer to a float64
func Float64Ptr(f float64) *float64 {
	return &f
}

// IntPtr returns a pointer to an int
func IntPtr(i int) *int {
	return &i
}

// TimePtr returns a pointer to a time.Time
func TimePtr(t time.Time) *time.Time {
	return &t
}
