-- Create operating_hours table
CREATE TYPE day_of_week AS ENUM ('MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY', 'SUNDAY');

CREATE TABLE IF NOT EXISTS operating_hours (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    location_id UUID NOT NULL REFERENCES locations(location_id) ON DELETE CASCADE,
    day_of_week day_of_week NOT NULL,
    open_time TIME NOT NULL,
    close_time TIME NOT NULL,
    is_closed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(location_id, day_of_week)
);

-- Create index on location_id for foreign key lookups
CREATE INDEX idx_operating_hours_location_id ON operating_hours(location_id);

-- Create trigger to update updated_at
CREATE TRIGGER update_operating_hours_updated_at BEFORE UPDATE ON operating_hours
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
