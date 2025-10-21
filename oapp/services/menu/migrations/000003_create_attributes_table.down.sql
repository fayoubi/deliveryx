-- Drop attributes table and related objects
DROP TRIGGER IF EXISTS update_attributes_updated_at ON attributes;
DROP TABLE IF EXISTS attributes CASCADE;
