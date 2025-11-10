-- Remove unique constraint on attribute_groups.name
ALTER TABLE attribute_groups DROP CONSTRAINT IF EXISTS attribute_groups_name_unique;
