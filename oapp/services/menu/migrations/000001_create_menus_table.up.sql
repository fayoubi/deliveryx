-- Create menus table
CREATE TYPE menu_status AS ENUM ('draft', 'pending_review', 'approved', 'active', 'rejected');

CREATE TABLE IF NOT EXISTS menus (
    menu_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    location_id UUID NOT NULL,
    status menu_status DEFAULT 'draft' NOT NULL,
    submitted_at TIMESTAMP WITH TIME ZONE,
    reviewed_at TIMESTAMP WITH TIME ZONE,
    rejection_reason TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(location_id)
);

-- Create index on location_id for lookups
CREATE INDEX idx_menus_location_id ON menus(location_id);

-- Create index on status for filtering
CREATE INDEX idx_menus_status ON menus(status);

-- Create trigger to update updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_menus_updated_at BEFORE UPDATE ON menus
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
