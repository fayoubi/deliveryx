-- Create collections table
CREATE TABLE IF NOT EXISTS collections (
    collection_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    menu_id UUID NOT NULL REFERENCES menus(menu_id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    position INTEGER DEFAULT 0,
    image_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CHECK (name IN ('Pizzas', 'Burgers', 'Sides', 'Desserts', 'Drinks', 'Salads', 'Breakfast', 'Sandwiches', 'Pasta', 'Seafood'))
);

-- Create index on menu_id for foreign key lookups
CREATE INDEX idx_collections_menu_id ON collections(menu_id);

-- Create index on position for ordering
CREATE INDEX idx_collections_position ON collections(position);

-- Create trigger to update updated_at
CREATE TRIGGER update_collections_updated_at BEFORE UPDATE ON collections
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
