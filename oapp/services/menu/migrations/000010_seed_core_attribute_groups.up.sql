-- Seed core universal attribute groups for diverse cuisines
-- This migration adds 9 essential attribute groups (Size already exists from 000008)

-- ============================================
-- 1. SPICE LEVEL (Universal)
-- ============================================
INSERT INTO attribute_groups (name, min_selections, max_selections, is_required, system_defined)
VALUES ('Spice Level', 1, 1, false, true)
ON CONFLICT (name) DO NOTHING;

INSERT INTO attributes (attribute_group_id, name, price_impact, is_default)
SELECT id, 'No Spice', 0, true FROM attribute_groups WHERE name = 'Spice Level'
ON CONFLICT DO NOTHING;

INSERT INTO attributes (attribute_group_id, name, price_impact, is_default)
SELECT id, 'Mild', 0, false FROM attribute_groups WHERE name = 'Spice Level'
ON CONFLICT DO NOTHING;

INSERT INTO attributes (attribute_group_id, name, price_impact, is_default)
SELECT id, 'Medium', 0, false FROM attribute_groups WHERE name = 'Spice Level'
ON CONFLICT DO NOTHING;

INSERT INTO attributes (attribute_group_id, name, price_impact, is_default)
SELECT id, 'Hot', 0, false FROM attribute_groups WHERE name = 'Spice Level'
ON CONFLICT DO NOTHING;

INSERT INTO attributes (attribute_group_id, name, price_impact, is_default)
SELECT id, 'Extra Hot', 0, false FROM attribute_groups WHERE name = 'Spice Level'
ON CONFLICT DO NOTHING;

INSERT INTO attributes (attribute_group_id, name, price_impact, is_default)
SELECT id, 'Thai Hot', 0, false FROM attribute_groups WHERE name = 'Spice Level'
ON CONFLICT DO NOTHING;

-- ============================================
-- 2. PROTEIN CHOICE (Universal)
-- ============================================
INSERT INTO attribute_groups (name, min_selections, max_selections, is_required, system_defined)
VALUES ('Protein Choice', 1, 1, false, true)
ON CONFLICT (name) DO NOTHING;

INSERT INTO attributes (attribute_group_id, name, price_impact, is_default)
SELECT id, 'Chicken', 0, true FROM attribute_groups WHERE name = 'Protein Choice'
ON CONFLICT DO NOTHING;

INSERT INTO attributes (attribute_group_id, name, price_impact, is_default)
SELECT id, 'Beef', 2.00, false FROM attribute_groups WHERE name = 'Protein Choice'
ON CONFLICT DO NOTHING;

INSERT INTO attributes (attribute_group_id, name, price_impact, is_default)
SELECT id, 'Pork', 1.50, false FROM attribute_groups WHERE name = 'Protein Choice'
ON CONFLICT DO NOTHING;

INSERT INTO attributes (attribute_group_id, name, price_impact, is_default)
SELECT id, 'Shrimp', 3.00, false FROM attribute_groups WHERE name = 'Protein Choice'
ON CONFLICT DO NOTHING;

INSERT INTO attributes (attribute_group_id, name, price_impact, is_default)
SELECT id, 'Tofu', 0, false FROM attribute_groups WHERE name = 'Protein Choice'
ON CONFLICT DO NOTHING;

INSERT INTO attributes (attribute_group_id, name, price_impact, is_default)
SELECT id, 'Mixed Seafood', 4.00, false FROM attribute_groups WHERE name = 'Protein Choice'
ON CONFLICT DO NOTHING;

INSERT INTO attributes (attribute_group_id, name, price_impact, is_default)
SELECT id, 'No Protein', -3.00, false FROM attribute_groups WHERE name = 'Protein Choice'
ON CONFLICT DO NOTHING;

-- ============================================
-- 3. SIDE CHOICE (Universal)
-- ============================================
INSERT INTO attribute_groups (name, min_selections, max_selections, is_required, system_defined)
VALUES ('Side Choice', 1, 1, false, true)
ON CONFLICT (name) DO NOTHING;

INSERT INTO attributes (attribute_group_id, name, price_impact, is_default)
SELECT id, 'White Rice', 0, true FROM attribute_groups WHERE name = 'Side Choice'
ON CONFLICT DO NOTHING;

INSERT INTO attributes (attribute_group_id, name, price_impact, is_default)
SELECT id, 'Brown Rice', 0.50, false FROM attribute_groups WHERE name = 'Side Choice'
ON CONFLICT DO NOTHING;

INSERT INTO attributes (attribute_group_id, name, price_impact, is_default)
SELECT id, 'Fried Rice', 2.00, false FROM attribute_groups WHERE name = 'Side Choice'
ON CONFLICT DO NOTHING;

INSERT INTO attributes (attribute_group_id, name, price_impact, is_default)
SELECT id, 'French Fries', 1.50, false FROM attribute_groups WHERE name = 'Side Choice'
ON CONFLICT DO NOTHING;

INSERT INTO attributes (attribute_group_id, name, price_impact, is_default)
SELECT id, 'Salad', 1.00, false FROM attribute_groups WHERE name = 'Side Choice'
ON CONFLICT DO NOTHING;

INSERT INTO attributes (attribute_group_id, name, price_impact, is_default)
SELECT id, 'Steamed Vegetables', 1.50, false FROM attribute_groups WHERE name = 'Side Choice'
ON CONFLICT DO NOTHING;

INSERT INTO attributes (attribute_group_id, name, price_impact, is_default)
SELECT id, 'No Side', -1.00, false FROM attribute_groups WHERE name = 'Side Choice'
ON CONFLICT DO NOTHING;

-- ============================================
-- 4. SAUCE PREFERENCE (Universal)
-- ============================================
INSERT INTO attribute_groups (name, min_selections, max_selections, is_required, system_defined)
VALUES ('Sauce Preference', 0, 1, false, true)
ON CONFLICT (name) DO NOTHING;

INSERT INTO attributes (attribute_group_id, name, price_impact, is_default)
SELECT id, 'On the Side', 0, true FROM attribute_groups WHERE name = 'Sauce Preference'
ON CONFLICT DO NOTHING;

INSERT INTO attributes (attribute_group_id, name, price_impact, is_default)
SELECT id, 'Light Sauce', 0, false FROM attribute_groups WHERE name = 'Sauce Preference'
ON CONFLICT DO NOTHING;

INSERT INTO attributes (attribute_group_id, name, price_impact, is_default)
SELECT id, 'Regular Sauce', 0, false FROM attribute_groups WHERE name = 'Sauce Preference'
ON CONFLICT DO NOTHING;

INSERT INTO attributes (attribute_group_id, name, price_impact, is_default)
SELECT id, 'Extra Sauce', 0.50, false FROM attribute_groups WHERE name = 'Sauce Preference'
ON CONFLICT DO NOTHING;

INSERT INTO attributes (attribute_group_id, name, price_impact, is_default)
SELECT id, 'No Sauce', 0, false FROM attribute_groups WHERE name = 'Sauce Preference'
ON CONFLICT DO NOTHING;

-- ============================================
-- 5. SPECIAL INSTRUCTIONS (Universal)
-- ============================================
INSERT INTO attribute_groups (name, min_selections, max_selections, is_required, system_defined)
VALUES ('Special Instructions', 0, 5, false, true)
ON CONFLICT (name) DO NOTHING;

INSERT INTO attributes (attribute_group_id, name, price_impact, is_default)
SELECT id, 'No Onions', 0, false FROM attribute_groups WHERE name = 'Special Instructions'
ON CONFLICT DO NOTHING;

INSERT INTO attributes (attribute_group_id, name, price_impact, is_default)
SELECT id, 'No Cilantro', 0, false FROM attribute_groups WHERE name = 'Special Instructions'
ON CONFLICT DO NOTHING;

INSERT INTO attributes (attribute_group_id, name, price_impact, is_default)
SELECT id, 'Extra Sauce', 0.50, false FROM attribute_groups WHERE name = 'Special Instructions'
ON CONFLICT DO NOTHING;

INSERT INTO attributes (attribute_group_id, name, price_impact, is_default)
SELECT id, 'Light Salt', 0, false FROM attribute_groups WHERE name = 'Special Instructions'
ON CONFLICT DO NOTHING;

INSERT INTO attributes (attribute_group_id, name, price_impact, is_default)
SELECT id, 'Well Done', 0, false FROM attribute_groups WHERE name = 'Special Instructions'
ON CONFLICT DO NOTHING;

INSERT INTO attributes (attribute_group_id, name, price_impact, is_default)
SELECT id, 'Less Oil', 0, false FROM attribute_groups WHERE name = 'Special Instructions'
ON CONFLICT DO NOTHING;

INSERT INTO attributes (attribute_group_id, name, price_impact, is_default)
SELECT id, 'Cut in Half', 0, false FROM attribute_groups WHERE name = 'Special Instructions'
ON CONFLICT DO NOTHING;

-- ============================================
-- 6. RICE/NOODLE TYPE (Asian Cuisine)
-- ============================================
INSERT INTO attribute_groups (name, min_selections, max_selections, is_required, system_defined)
VALUES ('Rice/Noodle Type', 1, 1, false, true)
ON CONFLICT (name) DO NOTHING;

INSERT INTO attributes (attribute_group_id, name, price_impact, is_default)
SELECT id, 'Steamed White Rice', 0, true FROM attribute_groups WHERE name = 'Rice/Noodle Type'
ON CONFLICT DO NOTHING;

INSERT INTO attributes (attribute_group_id, name, price_impact, is_default)
SELECT id, 'Steamed Brown Rice', 0.50, false FROM attribute_groups WHERE name = 'Rice/Noodle Type'
ON CONFLICT DO NOTHING;

INSERT INTO attributes (attribute_group_id, name, price_impact, is_default)
SELECT id, 'Fried Rice', 2.00, false FROM attribute_groups WHERE name = 'Rice/Noodle Type'
ON CONFLICT DO NOTHING;

INSERT INTO attributes (attribute_group_id, name, price_impact, is_default)
SELECT id, 'Rice Noodles', 0, false FROM attribute_groups WHERE name = 'Rice/Noodle Type'
ON CONFLICT DO NOTHING;

INSERT INTO attributes (attribute_group_id, name, price_impact, is_default)
SELECT id, 'Egg Noodles', 0, false FROM attribute_groups WHERE name = 'Rice/Noodle Type'
ON CONFLICT DO NOTHING;

INSERT INTO attributes (attribute_group_id, name, price_impact, is_default)
SELECT id, 'Udon', 1.00, false FROM attribute_groups WHERE name = 'Rice/Noodle Type'
ON CONFLICT DO NOTHING;

INSERT INTO attributes (attribute_group_id, name, price_impact, is_default)
SELECT id, 'Soba', 1.00, false FROM attribute_groups WHERE name = 'Rice/Noodle Type'
ON CONFLICT DO NOTHING;

INSERT INTO attributes (attribute_group_id, name, price_impact, is_default)
SELECT id, 'Sticky Rice', 1.00, false FROM attribute_groups WHERE name = 'Rice/Noodle Type'
ON CONFLICT DO NOTHING;

-- ============================================
-- 7. TORTILLA TYPE (Mexican Cuisine)
-- ============================================
INSERT INTO attribute_groups (name, min_selections, max_selections, is_required, system_defined)
VALUES ('Tortilla Type', 1, 1, false, true)
ON CONFLICT (name) DO NOTHING;

INSERT INTO attributes (attribute_group_id, name, price_impact, is_default)
SELECT id, 'Flour Tortilla', 0, true FROM attribute_groups WHERE name = 'Tortilla Type'
ON CONFLICT DO NOTHING;

INSERT INTO attributes (attribute_group_id, name, price_impact, is_default)
SELECT id, 'Corn Tortilla', 0, false FROM attribute_groups WHERE name = 'Tortilla Type'
ON CONFLICT DO NOTHING;

INSERT INTO attributes (attribute_group_id, name, price_impact, is_default)
SELECT id, 'Whole Wheat', 0.50, false FROM attribute_groups WHERE name = 'Tortilla Type'
ON CONFLICT DO NOTHING;

INSERT INTO attributes (attribute_group_id, name, price_impact, is_default)
SELECT id, 'Bowl (No Tortilla)', 0, false FROM attribute_groups WHERE name = 'Tortilla Type'
ON CONFLICT DO NOTHING;

INSERT INTO attributes (attribute_group_id, name, price_impact, is_default)
SELECT id, 'Hard Shell', 0.50, false FROM attribute_groups WHERE name = 'Tortilla Type'
ON CONFLICT DO NOTHING;

-- ============================================
-- 8. CRUST TYPE (Pizza/Italian Cuisine)
-- ============================================
INSERT INTO attribute_groups (name, min_selections, max_selections, is_required, system_defined)
VALUES ('Crust Type', 1, 1, false, true)
ON CONFLICT (name) DO NOTHING;

INSERT INTO attributes (attribute_group_id, name, price_impact, is_default)
SELECT id, 'Regular', 0, true FROM attribute_groups WHERE name = 'Crust Type'
ON CONFLICT DO NOTHING;

INSERT INTO attributes (attribute_group_id, name, price_impact, is_default)
SELECT id, 'Thin Crust', 0, false FROM attribute_groups WHERE name = 'Crust Type'
ON CONFLICT DO NOTHING;

INSERT INTO attributes (attribute_group_id, name, price_impact, is_default)
SELECT id, 'Thick Crust', 1.00, false FROM attribute_groups WHERE name = 'Crust Type'
ON CONFLICT DO NOTHING;

INSERT INTO attributes (attribute_group_id, name, price_impact, is_default)
SELECT id, 'Stuffed Crust', 3.00, false FROM attribute_groups WHERE name = 'Crust Type'
ON CONFLICT DO NOTHING;

INSERT INTO attributes (attribute_group_id, name, price_impact, is_default)
SELECT id, 'Gluten-Free', 3.00, false FROM attribute_groups WHERE name = 'Crust Type'
ON CONFLICT DO NOTHING;

-- ============================================
-- 9. COOKING TEMPERATURE (Burgers/Steaks)
-- ============================================
INSERT INTO attribute_groups (name, min_selections, max_selections, is_required, system_defined)
VALUES ('Cooking Temperature', 1, 1, false, true)
ON CONFLICT (name) DO NOTHING;

INSERT INTO attributes (attribute_group_id, name, price_impact, is_default)
SELECT id, 'Rare', 0, false FROM attribute_groups WHERE name = 'Cooking Temperature'
ON CONFLICT DO NOTHING;

INSERT INTO attributes (attribute_group_id, name, price_impact, is_default)
SELECT id, 'Medium Rare', 0, true FROM attribute_groups WHERE name = 'Cooking Temperature'
ON CONFLICT DO NOTHING;

INSERT INTO attributes (attribute_group_id, name, price_impact, is_default)
SELECT id, 'Medium', 0, false FROM attribute_groups WHERE name = 'Cooking Temperature'
ON CONFLICT DO NOTHING;

INSERT INTO attributes (attribute_group_id, name, price_impact, is_default)
SELECT id, 'Medium Well', 0, false FROM attribute_groups WHERE name = 'Cooking Temperature'
ON CONFLICT DO NOTHING;

INSERT INTO attributes (attribute_group_id, name, price_impact, is_default)
SELECT id, 'Well Done', 0, false FROM attribute_groups WHERE name = 'Cooking Temperature'
ON CONFLICT DO NOTHING;
