-- Drop attribute_groups table and related objects
DROP TRIGGER IF EXISTS update_attribute_groups_updated_at ON attribute_groups;
DROP TABLE IF EXISTS attribute_groups CASCADE;
