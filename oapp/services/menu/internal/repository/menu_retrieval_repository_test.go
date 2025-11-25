package repository

import (
	"database/sql"
	"regexp"
	"testing"

	"github.com/DATA-DOG/go-sqlmock"
	"github.com/deliveryx/menu-service/internal/testutil"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestMenuRetrievalRepository_GetCompleteMenu_Success(t *testing.T) {
	// Setup
	mockDB, err := testutil.NewMockDB()
	require.NoError(t, err)
	defer mockDB.Close()

	fixtures := testutil.NewTestFixtures()
	repo := NewMenuRetrievalRepository(mockDB.DB)

	// Mock menu exists check
	mockDB.Mock.ExpectQuery(regexp.QuoteMeta("SELECT EXISTS(SELECT 1 FROM menus WHERE menu_id = $1)")).
		WithArgs(fixtures.MenuID).
		WillReturnRows(sqlmock.NewRows([]string{"exists"}).AddRow(true))

	// Mock getAllAttributes query
	mockDB.Mock.ExpectQuery(regexp.QuoteMeta("SELECT id, name, price_impact, is_default FROM attributes ORDER BY attribute_group_id, name")).
		WillReturnRows(sqlmock.NewRows([]string{"id", "name", "price_impact", "is_default"}).
			AddRow(fixtures.AttributeID1, "Small", 0.0, false).
			AddRow(fixtures.AttributeID2, "Large", 2.5, true))

	// Mock getAllAttributeGroups query
	mockDB.Mock.ExpectQuery(regexp.QuoteMeta("SELECT id, name, min_selections, max_selections FROM attribute_groups ORDER BY name")).
		WillReturnRows(sqlmock.NewRows([]string{"id", "name", "min_selections", "max_selections"}).
			AddRow(fixtures.AttributeGroup, "Size", 1, 1))

	// Mock attributes for group query
	mockDB.Mock.ExpectQuery(regexp.QuoteMeta("SELECT id FROM attributes WHERE attribute_group_id = $1 ORDER BY name")).
		WithArgs(fixtures.AttributeGroup).
		WillReturnRows(sqlmock.NewRows([]string{"id"}).
			AddRow(fixtures.AttributeID1).
			AddRow(fixtures.AttributeID2))

	// Mock getMenuProducts query
	mockDB.Mock.ExpectQuery(regexp.QuoteMeta("SELECT DISTINCT p.product_id, p.name, p.price, p.image_url, p.description, p.is_available FROM products p INNER JOIN menu_products mp ON p.product_id = mp.product_id WHERE mp.menu_id = $1 ORDER BY p.name")).
		WithArgs(fixtures.MenuID).
		WillReturnRows(sqlmock.NewRows([]string{"product_id", "name", "price", "image_url", "description", "is_available"}).
			AddRow(fixtures.ProductID1, "Test Pizza", 12.99, "https://example.com/pizza.jpg", "Delicious pizza", true))

	// Mock product attribute groups query
	mockDB.Mock.ExpectQuery(regexp.QuoteMeta("SELECT attribute_group_id FROM product_attribute_groups WHERE product_id = $1")).
		WithArgs(fixtures.ProductID1).
		WillReturnRows(sqlmock.NewRows([]string{"attribute_group_id"}).
			AddRow(fixtures.AttributeGroup))

	// Mock getMenuCollections query
	mockDB.Mock.ExpectQuery(regexp.QuoteMeta("SELECT collection_id, name, position, image_url FROM collections WHERE menu_id = $1 ORDER BY position")).
		WithArgs(fixtures.MenuID).
		WillReturnRows(sqlmock.NewRows([]string{"collection_id", "name", "position", "image_url"}).
			AddRow(fixtures.CollectionID, "Main Dishes", 1, "https://example.com/collection.jpg"))

	// Mock collection products query
	mockDB.Mock.ExpectQuery(regexp.QuoteMeta("SELECT product_id, position FROM menu_products WHERE menu_id = $1 AND collection_id = $2 ORDER BY position")).
		WithArgs(fixtures.MenuID, fixtures.CollectionID).
		WillReturnRows(sqlmock.NewRows([]string{"product_id", "position"}).
			AddRow(fixtures.ProductID1, 1))

	// Execute
	result, err := repo.GetCompleteMenu(fixtures.MenuID)

	// Assert
	require.NoError(t, err)
	assert.NotNil(t, result)

	// Verify attributes
	assert.Len(t, result.Attributes, 2)
	assert.Equal(t, fixtures.AttributeID1, result.Attributes[0].ID)
	assert.Equal(t, "Small", result.Attributes[0].Name)
	assert.Equal(t, 0.0, result.Attributes[0].PriceImpact)
	assert.False(t, result.Attributes[0].SelectedByDefault)

	// Verify attribute groups
	assert.Len(t, result.AttributeGroups, 1)
	assert.Equal(t, fixtures.AttributeGroup, result.AttributeGroups[0].ID)
	assert.Equal(t, "Size", result.AttributeGroups[0].Name)
	assert.Equal(t, 1, result.AttributeGroups[0].Min)
	assert.Equal(t, 1, result.AttributeGroups[0].Max)
	assert.False(t, result.AttributeGroups[0].MultipleSelection)
	assert.Len(t, result.AttributeGroups[0].Attributes, 2)

	// Verify products
	assert.Len(t, result.Products, 1)
	assert.Equal(t, fixtures.ProductID1, result.Products[0].ID)
	assert.Equal(t, "Test Pizza", result.Products[0].Name)
	assert.Equal(t, 12.99, result.Products[0].Price)
	assert.True(t, result.Products[0].Available)
	assert.Len(t, result.Products[0].AttributesGroups, 1)

	// Verify collections
	assert.Len(t, result.Collections, 1)
	assert.Equal(t, "Main Dishes", result.Collections[0].Name)
	assert.Equal(t, 1, result.Collections[0].Position)
	assert.Len(t, result.Collections[0].Sections, 1)
	assert.Len(t, result.Collections[0].Sections[0].Products, 1)

	// Verify all expectations were met
	assert.NoError(t, mockDB.ExpectationsWereMet())
}

func TestMenuRetrievalRepository_GetCompleteMenu_MenuNotFound(t *testing.T) {
	// Setup
	mockDB, err := testutil.NewMockDB()
	require.NoError(t, err)
	defer mockDB.Close()

	fixtures := testutil.NewTestFixtures()
	repo := NewMenuRetrievalRepository(mockDB.DB)

	// Mock menu exists check - menu doesn't exist
	mockDB.Mock.ExpectQuery(regexp.QuoteMeta("SELECT EXISTS(SELECT 1 FROM menus WHERE menu_id = $1)")).
		WithArgs(fixtures.MenuID).
		WillReturnRows(sqlmock.NewRows([]string{"exists"}).AddRow(false))

	// Execute
	result, err := repo.GetCompleteMenu(fixtures.MenuID)

	// Assert
	assert.Error(t, err)
	assert.Nil(t, result)
	assert.Contains(t, err.Error(), "menu not found")

	// Verify all expectations were met
	assert.NoError(t, mockDB.ExpectationsWereMet())
}

func TestMenuRetrievalRepository_GetCompleteMenu_DatabaseError(t *testing.T) {
	// Setup
	mockDB, err := testutil.NewMockDB()
	require.NoError(t, err)
	defer mockDB.Close()

	fixtures := testutil.NewTestFixtures()
	repo := NewMenuRetrievalRepository(mockDB.DB)

	// Mock menu exists check with error
	mockDB.Mock.ExpectQuery(regexp.QuoteMeta("SELECT EXISTS(SELECT 1 FROM menus WHERE menu_id = $1)")).
		WithArgs(fixtures.MenuID).
		WillReturnError(sql.ErrConnDone)

	// Execute
	result, err := repo.GetCompleteMenu(fixtures.MenuID)

	// Assert
	assert.Error(t, err)
	assert.Nil(t, result)

	// Verify all expectations were met
	assert.NoError(t, mockDB.ExpectationsWereMet())
}

func TestMenuRetrievalRepository_GetCompleteMenu_EmptyMenu(t *testing.T) {
	// Setup - test menu with no products or collections
	mockDB, err := testutil.NewMockDB()
	require.NoError(t, err)
	defer mockDB.Close()

	fixtures := testutil.NewTestFixtures()
	repo := NewMenuRetrievalRepository(mockDB.DB)

	// Mock menu exists check
	mockDB.Mock.ExpectQuery(regexp.QuoteMeta("SELECT EXISTS(SELECT 1 FROM menus WHERE menu_id = $1)")).
		WithArgs(fixtures.MenuID).
		WillReturnRows(sqlmock.NewRows([]string{"exists"}).AddRow(true))

	// Mock getAllAttributes query - no attributes
	mockDB.Mock.ExpectQuery(regexp.QuoteMeta("SELECT id, name, price_impact, is_default FROM attributes ORDER BY attribute_group_id, name")).
		WillReturnRows(sqlmock.NewRows([]string{"id", "name", "price_impact", "is_default"}))

	// Mock getAllAttributeGroups query - no groups
	mockDB.Mock.ExpectQuery(regexp.QuoteMeta("SELECT id, name, min_selections, max_selections FROM attribute_groups ORDER BY name")).
		WillReturnRows(sqlmock.NewRows([]string{"id", "name", "min_selections", "max_selections"}))

	// Mock getMenuProducts query - no products
	mockDB.Mock.ExpectQuery(regexp.QuoteMeta("SELECT DISTINCT p.product_id, p.name, p.price, p.image_url, p.description, p.is_available FROM products p INNER JOIN menu_products mp ON p.product_id = mp.product_id WHERE mp.menu_id = $1 ORDER BY p.name")).
		WithArgs(fixtures.MenuID).
		WillReturnRows(sqlmock.NewRows([]string{"product_id", "name", "price", "image_url", "description", "is_available"}))

	// Mock getMenuCollections query - no collections
	mockDB.Mock.ExpectQuery(regexp.QuoteMeta("SELECT collection_id, name, position, image_url FROM collections WHERE menu_id = $1 ORDER BY position")).
		WithArgs(fixtures.MenuID).
		WillReturnRows(sqlmock.NewRows([]string{"collection_id", "name", "position", "image_url"}))

	// Execute
	result, err := repo.GetCompleteMenu(fixtures.MenuID)

	// Assert
	require.NoError(t, err)
	assert.NotNil(t, result)
	assert.Empty(t, result.Attributes)
	assert.Empty(t, result.AttributeGroups)
	assert.Empty(t, result.Products)
	assert.Empty(t, result.Collections)
	assert.NotNil(t, result.Supercollections)
	assert.NotNil(t, result.Packs)

	// Verify all expectations were met
	assert.NoError(t, mockDB.ExpectationsWereMet())
}

func TestMenuRetrievalRepository_GetAllAttributes_Success(t *testing.T) {
	// Setup
	mockDB, err := testutil.NewMockDB()
	require.NoError(t, err)
	defer mockDB.Close()

	fixtures := testutil.NewTestFixtures()
	repo := NewMenuRetrievalRepository(mockDB.DB)

	// Mock query
	mockDB.Mock.ExpectQuery(regexp.QuoteMeta("SELECT id, name, price_impact, is_default FROM attributes ORDER BY attribute_group_id, name")).
		WillReturnRows(sqlmock.NewRows([]string{"id", "name", "price_impact", "is_default"}).
			AddRow(fixtures.AttributeID1, "Small", 0.0, false).
			AddRow(fixtures.AttributeID2, "Large", 2.5, true))

	// Execute
	result, err := repo.getAllAttributes()

	// Assert
	require.NoError(t, err)
	assert.Len(t, result, 2)
	assert.Equal(t, "Small", result[0].Name)
	assert.Equal(t, "Large", result[1].Name)
	assert.True(t, result[1].SelectedByDefault)

	// Verify all expectations were met
	assert.NoError(t, mockDB.ExpectationsWereMet())
}

func TestMenuRetrievalRepository_GetAllAttributeGroups_MultipleSelection(t *testing.T) {
	// Setup
	mockDB, err := testutil.NewMockDB()
	require.NoError(t, err)
	defer mockDB.Close()

	fixtures := testutil.NewTestFixtures()
	repo := NewMenuRetrievalRepository(mockDB.DB)

	// Mock attribute groups query - max > 1 means multiple selection
	mockDB.Mock.ExpectQuery(regexp.QuoteMeta("SELECT id, name, min_selections, max_selections FROM attribute_groups ORDER BY name")).
		WillReturnRows(sqlmock.NewRows([]string{"id", "name", "min_selections", "max_selections"}).
			AddRow(fixtures.AttributeGroup, "Toppings", 0, 5))

	// Mock attributes for group query
	mockDB.Mock.ExpectQuery(regexp.QuoteMeta("SELECT id FROM attributes WHERE attribute_group_id = $1 ORDER BY name")).
		WithArgs(fixtures.AttributeGroup).
		WillReturnRows(sqlmock.NewRows([]string{"id"}).
			AddRow(fixtures.AttributeID1))

	// Execute
	result, err := repo.getAllAttributeGroups()

	// Assert
	require.NoError(t, err)
	assert.Len(t, result, 1)
	assert.True(t, result[0].MultipleSelection, "Should be multiple selection when max > 1")
	assert.Equal(t, 5, result[0].Max)

	// Verify all expectations were met
	assert.NoError(t, mockDB.ExpectationsWereMet())
}

func TestMenuRetrievalRepository_GetMenuProducts_WithoutAttributeGroups(t *testing.T) {
	// Setup
	mockDB, err := testutil.NewMockDB()
	require.NoError(t, err)
	defer mockDB.Close()

	fixtures := testutil.NewTestFixtures()
	repo := NewMenuRetrievalRepository(mockDB.DB)

	// Mock getMenuProducts query
	mockDB.Mock.ExpectQuery(regexp.QuoteMeta("SELECT DISTINCT p.product_id, p.name, p.price, p.image_url, p.description, p.is_available FROM products p INNER JOIN menu_products mp ON p.product_id = mp.product_id WHERE mp.menu_id = $1 ORDER BY p.name")).
		WithArgs(fixtures.MenuID).
		WillReturnRows(sqlmock.NewRows([]string{"product_id", "name", "price", "image_url", "description", "is_available"}).
			AddRow(fixtures.ProductID1, "Simple Product", 5.99, nil, nil, true))

	// Mock product attribute groups query - no attribute groups
	mockDB.Mock.ExpectQuery(regexp.QuoteMeta("SELECT attribute_group_id FROM product_attribute_groups WHERE product_id = $1")).
		WithArgs(fixtures.ProductID1).
		WillReturnRows(sqlmock.NewRows([]string{"attribute_group_id"}))

	// Execute
	result, err := repo.getMenuProducts(fixtures.MenuID)

	// Assert
	require.NoError(t, err)
	assert.Len(t, result, 1)
	assert.Equal(t, "Simple Product", result[0].Name)
	assert.NotNil(t, result[0].AttributesGroups)
	assert.Empty(t, result[0].AttributesGroups, "Should return empty array, not nil")

	// Verify all expectations were met
	assert.NoError(t, mockDB.ExpectationsWereMet())
}

func TestMenuRetrievalRepository_GetMenuCollections_EmptyCollection(t *testing.T) {
	// Setup
	mockDB, err := testutil.NewMockDB()
	require.NoError(t, err)
	defer mockDB.Close()

	fixtures := testutil.NewTestFixtures()
	repo := NewMenuRetrievalRepository(mockDB.DB)

	// Mock getMenuCollections query
	mockDB.Mock.ExpectQuery(regexp.QuoteMeta("SELECT collection_id, name, position, image_url FROM collections WHERE menu_id = $1 ORDER BY position")).
		WithArgs(fixtures.MenuID).
		WillReturnRows(sqlmock.NewRows([]string{"collection_id", "name", "position", "image_url"}).
			AddRow(fixtures.CollectionID, "Empty Collection", 1, nil))

	// Mock collection products query - no products
	mockDB.Mock.ExpectQuery(regexp.QuoteMeta("SELECT product_id, position FROM menu_products WHERE menu_id = $1 AND collection_id = $2 ORDER BY position")).
		WithArgs(fixtures.MenuID, fixtures.CollectionID).
		WillReturnRows(sqlmock.NewRows([]string{"product_id", "position"}))

	// Execute
	result, err := repo.getMenuCollections(fixtures.MenuID)

	// Assert
	require.NoError(t, err)
	assert.Len(t, result, 1)
	assert.Equal(t, "Empty Collection", result[0].Name)
	assert.NotNil(t, result[0].Sections)
	assert.Empty(t, result[0].Sections, "Empty collection should have empty sections array")

	// Verify all expectations were met
	assert.NoError(t, mockDB.ExpectationsWereMet())
}
