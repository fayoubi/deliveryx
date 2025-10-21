-- Drop stores table and related objects
DROP TRIGGER IF EXISTS update_stores_updated_at ON stores;
DROP TABLE IF EXISTS stores CASCADE;
DROP FUNCTION IF EXISTS update_updated_at_column();
