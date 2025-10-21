-- Drop menus table and related objects
DROP TRIGGER IF EXISTS update_menus_updated_at ON menus;
DROP TABLE IF EXISTS menus CASCADE;
DROP TYPE IF EXISTS menu_status CASCADE;
DROP FUNCTION IF EXISTS update_updated_at_column();
