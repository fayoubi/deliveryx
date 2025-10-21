-- Create attribute_groups table
CREATE TABLE IF NOT EXISTS attribute_groups (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    min_selections INTEGER DEFAULT 0,
    max_selections INTEGER DEFAULT 1,
    is_required BOOLEAN DEFAULT FALSE,
    system_defined BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create index on name
CREATE INDEX idx_attribute_groups_name ON attribute_groups(name);

-- Create trigger to update updated_at
CREATE TRIGGER update_attribute_groups_updated_at BEFORE UPDATE ON attribute_groups
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
