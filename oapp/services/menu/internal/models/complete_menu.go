package models

// CompleteMenuResponse represents the complete menu structure
type CompleteMenuResponse struct {
	Attributes       []MenuAttribute       `json:"attributes"`
	AttributeGroups  []MenuAttributeGroup  `json:"attribute_groups"`
	Products         []MenuProductItem     `json:"products"`
	Collections      []MenuCollection      `json:"collections"`
	Supercollections []interface{}         `json:"supercollections,omitempty"`
	Packs            []interface{}         `json:"packs,omitempty"`
}

// MenuAttribute represents an attribute in menu format
type MenuAttribute struct {
	ID                string  `json:"id"`
	Name              string  `json:"name"`
	SelectedByDefault bool    `json:"selected_by_default"`
	PriceImpact       float64 `json:"price_impact"`
	Available         bool    `json:"available,omitempty"`
}

// MenuAttributeGroup represents an attribute group in menu format
type MenuAttributeGroup struct {
	ID                string   `json:"id"`
	Name              string   `json:"name"`
	Min               int      `json:"min"`
	Max               int      `json:"max"`
	Collapse          bool     `json:"collapse"`
	MultipleSelection bool     `json:"multiple_selection"`
	Attributes        []string `json:"attributes"`
}

// MenuProductItem represents a product in menu format
type MenuProductItem struct {
	ID              string   `json:"id"`
	Name            string   `json:"name"`
	Price           float64  `json:"price"`
	ImageURL        *string  `json:"image_url"`
	Description     *string  `json:"description"`
	AttributesGroups []string `json:"attributes_groups"`
	Available       bool     `json:"available"`
}

// MenuCollection represents a collection in menu format
type MenuCollection struct {
	Name     string        `json:"name"`
	Position int           `json:"position"`
	ImageURL *string       `json:"image_url,omitempty"`
	Sections []MenuSection `json:"sections"`
}

// MenuSection represents a section in menu format
type MenuSection struct {
	Name     string   `json:"name"`
	Position int      `json:"position"`
	Products []string `json:"products"`
}
