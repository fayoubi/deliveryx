-- Create attributes table
CREATE TABLE IF NOT EXISTS attributes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    attribute_group_id UUID NOT NULL REFERENCES attribute_groups(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    price_impact DECIMAL(10, 2) DEFAULT 0,
    is_default BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create index on attribute_group_id for foreign key lookups
CREATE INDEX idx_attributes_group_id ON attributes(attribute_group_id);

-- Create trigger to update updated_at
CREATE TRIGGER update_attributes_updated_at BEFORE UPDATE ON attributes
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
