# Attribute Groups Seeding Report

**Migration:** `000010_seed_core_attribute_groups.up.sql`
**Executed:** November 7, 2025 @ 17:47 UTC
**Status:** ✅ SUCCESS
**Database:** `deliveryx_menu`

---

## Summary

### Migration Statistics
- **Total Attribute Groups:** 12 (3 pre-existing + 9 newly added)
- **Total Attributes:** 67
- **All Groups System-Defined:** Yes (`system_defined = true`)
- **Idempotency:** Enabled via unique constraint on `attribute_groups.name`

### Pre-Existing Groups (From Migration 000008)
1. **Size** - 4 attributes
2. **Cuisson** - 3 attributes
3. **Color** - 5 attributes

### Newly Added Groups (Migration 000010)
1. **Spice Level** - 6 attributes
2. **Protein Choice** - 7 attributes
3. **Side Choice** - 7 attributes
4. **Sauce Preference** - 5 attributes
5. **Special Instructions** - 7 attributes
6. **Rice/Noodle Type** - 8 attributes
7. **Tortilla Type** - 5 attributes
8. **Crust Type** - 5 attributes
9. **Cooking Temperature** - 5 attributes

---

## Detailed Breakdown

### 1. Spice Level (Universal) 🌶️
**Configuration:**
- Min Selections: 1
- Max Selections: 1
- Required: No
- Multiple Selection: No

**Attributes (6):**
| Attribute | Price Impact | Default |
|-----------|-------------|---------|
| No Spice | $0.00 | ✅ |
| Mild | $0.00 | |
| Medium | $0.00 | |
| Hot | $0.00 | |
| Extra Hot | $0.00 | |
| Thai Hot | $0.00 | |

**Use Cases:** Asian, Mexican, Indian, Thai cuisine

---

### 2. Protein Choice (Universal) 🍗
**Configuration:**
- Min Selections: 1
- Max Selections: 1
- Required: No
- Multiple Selection: No

**Attributes (7):**
| Attribute | Price Impact | Default |
|-----------|-------------|---------|
| Chicken | $0.00 | ✅ |
| Beef | +$2.00 | |
| Pork | +$1.50 | |
| Shrimp | +$3.00 | |
| Tofu | $0.00 | |
| Mixed Seafood | +$4.00 | |
| No Protein | -$3.00 | |

**Use Cases:** Stir fry, noodles, rice bowls, salads, tacos

---

### 3. Side Choice (Universal) 🍚
**Configuration:**
- Min Selections: 1
- Max Selections: 1
- Required: No
- Multiple Selection: No

**Attributes (7):**
| Attribute | Price Impact | Default |
|-----------|-------------|---------|
| White Rice | $0.00 | ✅ |
| Brown Rice | +$0.50 | |
| Fried Rice | +$2.00 | |
| French Fries | +$1.50 | |
| Salad | +$1.00 | |
| Steamed Vegetables | +$1.50 | |
| No Side | -$1.00 | |

**Use Cases:** Main dishes, combo meals, platters

---

### 4. Sauce Preference (Universal) 🥫
**Configuration:**
- Min Selections: 0
- Max Selections: 1
- Required: No
- Multiple Selection: No

**Attributes (5):**
| Attribute | Price Impact | Default |
|-----------|-------------|---------|
| On the Side | $0.00 | ✅ |
| Light Sauce | $0.00 | |
| Regular Sauce | $0.00 | |
| Extra Sauce | +$0.50 | |
| No Sauce | $0.00 | |

**Use Cases:** All cuisines with sauced dishes

---

### 5. Special Instructions (Universal) 📝
**Configuration:**
- Min Selections: 0
- Max Selections: 5
- Required: No
- Multiple Selection: Yes (up to 5)

**Attributes (7):**
| Attribute | Price Impact | Default |
|-----------|-------------|---------|
| No Onions | $0.00 | |
| No Cilantro | $0.00 | |
| Extra Sauce | +$0.50 | |
| Light Salt | $0.00 | |
| Well Done | $0.00 | |
| Less Oil | $0.00 | |
| Cut in Half | $0.00 | |

**Use Cases:** All cuisines - customer customization

---

### 6. Rice/Noodle Type (Asian Cuisine) 🍜
**Configuration:**
- Min Selections: 1
- Max Selections: 1
- Required: No
- Multiple Selection: No

**Attributes (8):**
| Attribute | Price Impact | Default |
|-----------|-------------|---------|
| Steamed White Rice | $0.00 | ✅ |
| Steamed Brown Rice | +$0.50 | |
| Fried Rice | +$2.00 | |
| Rice Noodles | $0.00 | |
| Egg Noodles | $0.00 | |
| Udon | +$1.00 | |
| Soba | +$1.00 | |
| Sticky Rice | +$1.00 | |

**Use Cases:** Chinese, Japanese, Thai, Vietnamese dishes

---

### 7. Tortilla Type (Mexican Cuisine) 🌮
**Configuration:**
- Min Selections: 1
- Max Selections: 1
- Required: No
- Multiple Selection: No

**Attributes (5):**
| Attribute | Price Impact | Default |
|-----------|-------------|---------|
| Flour Tortilla | $0.00 | ✅ |
| Corn Tortilla | $0.00 | |
| Whole Wheat | +$0.50 | |
| Bowl (No Tortilla) | $0.00 | |
| Hard Shell | +$0.50 | |

**Use Cases:** Tacos, burritos, quesadillas

---

### 8. Crust Type (Pizza/Italian) 🍕
**Configuration:**
- Min Selections: 1
- Max Selections: 1
- Required: No
- Multiple Selection: No

**Attributes (5):**
| Attribute | Price Impact | Default |
|-----------|-------------|---------|
| Regular | $0.00 | ✅ |
| Thin Crust | $0.00 | |
| Thick Crust | +$1.00 | |
| Stuffed Crust | +$3.00 | |
| Gluten-Free | +$3.00 | |

**Use Cases:** Pizzas, calzones

---

### 9. Cooking Temperature (Burgers/Steaks) 🥩
**Configuration:**
- Min Selections: 1
- Max Selections: 1
- Required: No
- Multiple Selection: No

**Attributes (5):**
| Attribute | Price Impact | Default |
|-----------|-------------|---------|
| Rare | $0.00 | |
| Medium Rare | $0.00 | ✅ |
| Medium | $0.00 | |
| Medium Well | $0.00 | |
| Well Done | $0.00 | |

**Use Cases:** Burgers, steaks, beef dishes

---

### 10. Size (Pre-existing) 📏
**Configuration:**
- Min Selections: 1
- Max Selections: 1
- Required: Yes
- Multiple Selection: No

**Attributes (4):**
| Attribute | Price Impact | Default |
|-----------|-------------|---------|
| S | $0.00 | |
| M | +$20.00 | ✅ |
| L | +$40.00 | |
| XL | +$60.00 | |

**Use Cases:** Beverages, pizzas, portions

---

### 11. Cuisson (Pre-existing) 🔥
**Configuration:**
- Min Selections: 1
- Max Selections: 1
- Required: No
- Multiple Selection: No

**Attributes (3):**
| Attribute | Price Impact | Default |
|-----------|-------------|---------|
| Cru | $0.00 | |
| Bien cuit | $0.00 | ✅ |
| Brûlé | $0.00 | |

**Use Cases:** French cuisine, meats

---

### 12. Color (Pre-existing) 🎨
**Configuration:**
- Min Selections: 0
- Max Selections: 5
- Required: No
- Multiple Selection: Yes (up to 5)

**Attributes (5):**
| Attribute | Price Impact | Default |
|-----------|-------------|---------|
| Blue | $0.00 | |
| Red | $0.00 | |
| Green | $0.00 | |
| Black | $0.00 | |
| White | $0.00 | |

**Use Cases:** Testing/demo purposes

---

## Usage Examples

### Example 1: Pizza Product
```
Product: "Margherita Pizza"
Applicable Attribute Groups:
  - Size (required)
  - Crust Type
  - Spice Level (if spicy variant)
  - Special Instructions
```

### Example 2: Asian Stir Fry
```
Product: "Chicken Stir Fry"
Applicable Attribute Groups:
  - Protein Choice
  - Rice/Noodle Type
  - Spice Level
  - Sauce Preference
  - Special Instructions
```

### Example 3: Mexican Burrito
```
Product: "Beef Burrito"
Applicable Attribute Groups:
  - Protein Choice
  - Tortilla Type
  - Spice Level
  - Side Choice
  - Special Instructions
```

### Example 4: Burger
```
Product: "Classic Burger"
Applicable Attribute Groups:
  - Size
  - Cooking Temperature
  - Side Choice (fries, salad, etc.)
  - Special Instructions
```

---

## Technical Notes

### Database Changes
1. **Added unique constraint:** `attribute_groups_name_unique` on `attribute_groups.name`
2. **All UUIDs auto-generated:** Using PostgreSQL's `gen_random_uuid()`
3. **Idempotent inserts:** Using `ON CONFLICT (name) DO NOTHING`
4. **Foreign key references:** Using subquery `SELECT id FROM attribute_groups WHERE name = 'X'`

### Rollback
To rollback this migration:
```bash
docker-compose exec postgres psql -U deliveryx -d deliveryx_menu \
  -f /path/to/000010_seed_core_attribute_groups.down.sql
```

This will remove only the 9 newly added groups while preserving Size, Cuisson, and Color.

---

## Next Steps for UI Development

### 1. Product Creation Form
Add multi-select dropdown for attribute groups:
```javascript
<AttributeGroupSelector
  availableGroups={attributeGroups}
  selectedGroups={productAttributeGroups}
  onChange={handleAttributeGroupChange}
/>
```

### 2. Menu Display
Show applicable customization options per product:
```javascript
<ProductCustomization
  product={product}
  attributeGroups={product.attribute_groups}
  onSelect={handleAttributeSelection}
/>
```

### 3. Price Calculation
Implement dynamic pricing:
```javascript
const totalPrice = basePrice + selectedAttributes
  .reduce((sum, attr) => sum + attr.price_impact, 0);
```

### 4. Validation
Enforce min/max selections:
```javascript
const isValid = (selectedCount >= minSelections) &&
                (selectedCount <= maxSelections);
```

---

## API Endpoints

### Get All Attribute Groups
```bash
GET /api/v1/attribute-groups
```

### Get Attributes for a Group
```bash
GET /api/v1/attribute-groups/{id}/attributes
```

### Link Attribute Group to Product
```bash
# During product creation
POST /api/v1/locations/{location_id}/products
{
  "name": "Margherita Pizza",
  "price": 12.99,
  "attribute_group_ids": [
    "size-group-uuid",
    "crust-type-uuid",
    "spice-level-uuid"
  ]
}
```

---

## Success Metrics

✅ **9 new attribute groups** added
✅ **55 new attributes** created
✅ **12 total groups** available
✅ **67 total attributes** available
✅ **100% system-defined** for consistency
✅ **Zero manual UUIDs** - all auto-generated
✅ **Idempotent migration** - can run multiple times safely

---

*Report generated: November 7, 2025*
*Database: deliveryx_menu @ PostgreSQL 16*
