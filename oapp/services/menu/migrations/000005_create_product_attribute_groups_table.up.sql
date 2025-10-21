-- Create product_attribute_groups junction table
CREATE TABLE IF NOT EXISTS product_attribute_groups (
    product_id UUID NOT NULL REFERENCES products(product_id) ON DELETE CASCADE,
    attribute_group_id UUID NOT NULL REFERENCES attribute_groups(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (product_id, attribute_group_id)
);

-- Create indexes for foreign key lookups
CREATE INDEX idx_product_attribute_groups_product_id ON product_attribute_groups(product_id);
CREATE INDEX idx_product_attribute_groups_attribute_group_id ON product_attribute_groups(attribute_group_id);
