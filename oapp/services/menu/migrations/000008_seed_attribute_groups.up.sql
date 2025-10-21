-- Seed predefined attribute groups and attributes (Epic 2, US-2.2)

-- Insert attribute groups
INSERT INTO attribute_groups (id, name, min_selections, max_selections, is_required, system_defined) VALUES
    ('11111111-1111-1111-1111-111111111111', 'Size', 1, 1, true, true),
    ('22222222-2222-2222-2222-222222222222', 'Cuisson', 1, 1, false, true),
    ('33333333-3333-3333-3333-333333333333', 'Color', 0, 5, false, true);

-- Insert Size attributes
INSERT INTO attributes (attribute_group_id, name, price_impact, is_default) VALUES
    ('11111111-1111-1111-1111-111111111111', 'S', 0, false),
    ('11111111-1111-1111-1111-111111111111', 'M', 20, true),
    ('11111111-1111-1111-1111-111111111111', 'L', 40, false),
    ('11111111-1111-1111-1111-111111111111', 'XL', 60, false);

-- Insert Cuisson attributes
INSERT INTO attributes (attribute_group_id, name, price_impact, is_default) VALUES
    ('22222222-2222-2222-2222-222222222222', 'Cru', 0, false),
    ('22222222-2222-2222-2222-222222222222', 'Bien cuit', 0, true),
    ('22222222-2222-2222-2222-222222222222', 'Brûlé', 0, false);

-- Insert Color attributes
INSERT INTO attributes (attribute_group_id, name, price_impact, is_default) VALUES
    ('33333333-3333-3333-3333-333333333333', 'Blue', 0, false),
    ('33333333-3333-3333-3333-333333333333', 'Red', 0, false),
    ('33333333-3333-3333-3333-333333333333', 'Green', 0, false),
    ('33333333-3333-3333-3333-333333333333', 'Black', 0, false),
    ('33333333-3333-3333-3333-333333333333', 'White', 0, false);
