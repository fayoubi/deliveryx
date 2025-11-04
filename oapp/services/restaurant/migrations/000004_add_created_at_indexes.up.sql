-- Add indexes on created_at for both stores and locations to support sorting
CREATE INDEX IF NOT EXISTS idx_stores_created_at ON stores(created_at);
CREATE INDEX IF NOT EXISTS idx_locations_created_at ON locations(created_at);
