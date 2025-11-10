-- Rollback core attribute groups seeding
-- This removes the 9 attribute groups added in 000010 (preserves Size, Cuisson, Color from 000008)

-- Delete attributes first (due to foreign key constraints)
DELETE FROM attributes WHERE attribute_group_id IN (
    SELECT id FROM attribute_groups WHERE name IN (
        'Spice Level',
        'Protein Choice',
        'Side Choice',
        'Sauce Preference',
        'Special Instructions',
        'Rice/Noodle Type',
        'Tortilla Type',
        'Crust Type',
        'Cooking Temperature'
    )
);

-- Delete attribute groups
DELETE FROM attribute_groups WHERE name IN (
    'Spice Level',
    'Protein Choice',
    'Side Choice',
    'Sauce Preference',
    'Special Instructions',
    'Rice/Noodle Type',
    'Tortilla Type',
    'Crust Type',
    'Cooking Temperature'
);
