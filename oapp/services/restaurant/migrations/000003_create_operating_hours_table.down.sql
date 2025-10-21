-- Drop operating_hours table and related objects
DROP TRIGGER IF EXISTS update_operating_hours_updated_at ON operating_hours;
DROP TABLE IF EXISTS operating_hours CASCADE;
DROP TYPE IF EXISTS day_of_week CASCADE;
