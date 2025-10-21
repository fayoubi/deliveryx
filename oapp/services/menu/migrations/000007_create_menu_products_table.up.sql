-- Create menu_products junction table
CREATE TABLE IF NOT EXISTS menu_products (
    menu_id UUID NOT NULL REFERENCES menus(menu_id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(product_id) ON DELETE CASCADE,
    collection_id UUID NOT NULL REFERENCES collections(collection_id) ON DELETE CASCADE,
    section_id UUID,
    position INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (menu_id, product_id),
    UNIQUE (menu_id, product_id)
);

-- Create indexes for foreign key lookups
CREATE INDEX idx_menu_products_menu_id ON menu_products(menu_id);
CREATE INDEX idx_menu_products_product_id ON menu_products(product_id);
CREATE INDEX idx_menu_products_collection_id ON menu_products(collection_id);
CREATE INDEX idx_menu_products_position ON menu_products(collection_id, position);
