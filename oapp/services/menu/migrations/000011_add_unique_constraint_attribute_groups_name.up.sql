-- Add unique constraint on attribute_groups.name for idempotency
-- This enables ON CONFLICT (name) DO NOTHING in seeding migrations
ALTER TABLE attribute_groups ADD CONSTRAINT attribute_groups_name_unique UNIQUE (name);
