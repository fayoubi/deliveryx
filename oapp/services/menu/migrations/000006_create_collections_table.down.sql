-- Drop collections table and related objects
DROP TRIGGER IF EXISTS update_collections_updated_at ON collections;
DROP TABLE IF EXISTS collections CASCADE;
