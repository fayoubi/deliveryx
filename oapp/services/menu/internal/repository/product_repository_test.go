package repository

import (
	"database/sql"
	"regexp"
	"testing"
	"time"

	"github.com/DATA-DOG/go-sqlmock"
	"github.com/deliveryx/menu-service/internal/models"
	"github.com/deliveryx/menu-service/internal/testutil"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestProductRepository_Create_Success(t *testing.T) {
	// Setup
	mockDB, err := testutil.NewMockDB()
	require.NoError(t, err)
	defer mockDB.Close()

	fixtures := testutil.NewTestFixtures()
	repo := NewProductRepository(mockDB.DB)

	req := &models.CreateProductRequest{
		Name:              "Test Pizza",
		Description:       testutil.StringPtr("Delicious test pizza"),
		Price:             12.99,
		Category:          testutil.StringPtr("Main Course"),
		ImageURL:          testutil.StringPtr("https://example.com/pizza.jpg"),
		AttributeGroupIDs: []string{fixtures.AttributeGroup},
	}

	// Mock transaction
	mockDB.Mock.ExpectBegin()

	// Mock insert product
	now := time.Now()
	mockDB.Mock.ExpectQuery(regexp.QuoteMeta("INSERT INTO products (product_id, location_id, name, description, price, category, image_url, is_available) VALUES ($1, $2, $3, $4, $5, $6, $7, true) RETURNING created_at, updated_at")).
		WithArgs(sqlmock.AnyArg(), fixtures.LocationID, req.Name, req.Description, req.Price, req.Category, req.ImageURL).
		WillReturnRows(sqlmock.NewRows([]string{"created_at", "updated_at"}).
			AddRow(now, now))

	// Mock insert attribute group association
	mockDB.Mock.ExpectExec(regexp.QuoteMeta("INSERT INTO product_attribute_groups (product_id, attribute_group_id) VALUES ($1, $2)")).
		WithArgs(sqlmock.AnyArg(), fixtures.AttributeGroup).
		WillReturnResult(sqlmock.NewResult(1, 1))

	mockDB.Mock.ExpectCommit()

	// Execute
	result, err := repo.Create(fixtures.LocationID, req)

	// Assert
	require.NoError(t, err)
	assert.NotNil(t, result)
	assert.NotEmpty(t, result.ProductID)
	assert.Equal(t, fixtures.LocationID, result.LocationID)
	assert.Equal(t, "Test Pizza", result.Name)
	assert.Equal(t, 12.99, result.Price)
	assert.True(t, result.IsAvailable)
	assert.Len(t, result.AttributeGroupIDs, 1)

	// Verify all expectations were met
	assert.NoError(t, mockDB.ExpectationsWereMet())
}

func TestProductRepository_Create_WithoutAttributeGroups(t *testing.T) {
	// Setup
	mockDB, err := testutil.NewMockDB()
	require.NoError(t, err)
	defer mockDB.Close()

	fixtures := testutil.NewTestFixtures()
	repo := NewProductRepository(mockDB.DB)

	req := &models.CreateProductRequest{
		Name:              "Simple Product",
		Price:             5.99,
		AttributeGroupIDs: []string{},
	}

	// Mock transaction
	mockDB.Mock.ExpectBegin()

	// Mock insert product
	now := time.Now()
	mockDB.Mock.ExpectQuery(regexp.QuoteMeta("INSERT INTO products (product_id, location_id, name, description, price, category, image_url, is_available) VALUES ($1, $2, $3, $4, $5, $6, $7, true) RETURNING created_at, updated_at")).
		WithArgs(sqlmock.AnyArg(), fixtures.LocationID, req.Name, req.Description, req.Price, req.Category, req.ImageURL).
		WillReturnRows(sqlmock.NewRows([]string{"created_at", "updated_at"}).
			AddRow(now, now))

	mockDB.Mock.ExpectCommit()

	// Execute
	result, err := repo.Create(fixtures.LocationID, req)

	// Assert
	require.NoError(t, err)
	assert.NotNil(t, result)
	assert.Empty(t, result.AttributeGroupIDs)

	// Verify all expectations were met
	assert.NoError(t, mockDB.ExpectationsWereMet())
}

func TestProductRepository_GetByID_Success(t *testing.T) {
	// Setup
	mockDB, err := testutil.NewMockDB()
	require.NoError(t, err)
	defer mockDB.Close()

	fixtures := testutil.NewTestFixtures()
	repo := NewProductRepository(mockDB.DB)

	// Mock get product query
	mockDB.Mock.ExpectQuery(regexp.QuoteMeta("SELECT product_id, location_id, name, description, price, category, image_url, is_available, created_at, updated_at FROM products WHERE product_id = $1")).
		WithArgs(fixtures.ProductID1).
		WillReturnRows(sqlmock.NewRows([]string{
			"product_id", "location_id", "name", "description", "price", "category", "image_url", "is_available", "created_at", "updated_at",
		}).AddRow(
			fixtures.ProductID1, fixtures.LocationID, "Test Pizza", "Delicious pizza",
			12.99, "Main Course", "https://example.com/pizza.jpg", true,
			time.Now(), time.Now(),
		))

	// Mock get attribute groups query
	mockDB.Mock.ExpectQuery(regexp.QuoteMeta("SELECT attribute_group_id FROM product_attribute_groups WHERE product_id = $1")).
		WithArgs(fixtures.ProductID1).
		WillReturnRows(sqlmock.NewRows([]string{"attribute_group_id"}).
			AddRow(fixtures.AttributeGroup))

	// Execute
	result, err := repo.GetByID(fixtures.ProductID1)

	// Assert
	require.NoError(t, err)
	assert.NotNil(t, result)
	assert.Equal(t, fixtures.ProductID1, result.ProductID)
	assert.Equal(t, "Test Pizza", result.Name)
	assert.Len(t, result.AttributeGroupIDs, 1)

	// Verify all expectations were met
	assert.NoError(t, mockDB.ExpectationsWereMet())
}

func TestProductRepository_GetByID_NotFound(t *testing.T) {
	// Setup
	mockDB, err := testutil.NewMockDB()
	require.NoError(t, err)
	defer mockDB.Close()

	fixtures := testutil.NewTestFixtures()
	repo := NewProductRepository(mockDB.DB)

	// Mock get product query - not found
	mockDB.Mock.ExpectQuery(regexp.QuoteMeta("SELECT product_id, location_id, name, description, price, category, image_url, is_available, created_at, updated_at FROM products WHERE product_id = $1")).
		WithArgs(fixtures.ProductID1).
		WillReturnError(sql.ErrNoRows)

	// Execute
	result, err := repo.GetByID(fixtures.ProductID1)

	// Assert
	assert.Error(t, err)
	assert.Nil(t, result)
	assert.Contains(t, err.Error(), "product not found")

	// Verify all expectations were met
	assert.NoError(t, mockDB.ExpectationsWereMet())
}

func TestProductRepository_Update_Success(t *testing.T) {
	// Setup
	mockDB, err := testutil.NewMockDB()
	require.NoError(t, err)
	defer mockDB.Close()

	fixtures := testutil.NewTestFixtures()
	repo := NewProductRepository(mockDB.DB)

	newName := "Updated Pizza"
	newPrice := 14.99
	req := &models.UpdateProductRequest{
		Name:  &newName,
		Price: &newPrice,
	}

	// Mock check menu status (should be draft or not exist)
	mockDB.Mock.ExpectQuery(regexp.QuoteMeta("SELECT EXISTS( SELECT 1 FROM menu_products mp INNER JOIN menus m ON mp.menu_id = m.menu_id WHERE mp.product_id = $1 AND m.status != 'draft' )")).
		WithArgs(fixtures.ProductID1).
		WillReturnRows(sqlmock.NewRows([]string{"exists"}).AddRow(false))

	// Mock transaction
	mockDB.Mock.ExpectBegin()

	// Mock update product
	mockDB.Mock.ExpectExec(regexp.QuoteMeta("UPDATE products SET name = $1, price = $2 WHERE product_id = $3")).
		WithArgs(newName, newPrice, fixtures.ProductID1).
		WillReturnResult(sqlmock.NewResult(0, 1))

	mockDB.Mock.ExpectCommit()

	// Mock GetByID call after update
	mockDB.Mock.ExpectQuery(regexp.QuoteMeta("SELECT product_id, location_id, name, description, price, category, image_url, is_available, created_at, updated_at FROM products WHERE product_id = $1")).
		WithArgs(fixtures.ProductID1).
		WillReturnRows(sqlmock.NewRows([]string{
			"product_id", "location_id", "name", "description", "price", "category", "image_url", "is_available", "created_at", "updated_at",
		}).AddRow(
			fixtures.ProductID1, fixtures.LocationID, newName, "Description",
			newPrice, "Category", "url", true,
			time.Now(), time.Now(),
		))

	mockDB.Mock.ExpectQuery(regexp.QuoteMeta("SELECT attribute_group_id FROM product_attribute_groups WHERE product_id = $1")).
		WithArgs(fixtures.ProductID1).
		WillReturnRows(sqlmock.NewRows([]string{"attribute_group_id"}))

	// Execute
	result, err := repo.Update(fixtures.ProductID1, req)

	// Assert
	require.NoError(t, err)
	assert.NotNil(t, result)
	assert.Equal(t, newName, result.Name)
	assert.Equal(t, newPrice, result.Price)

	// Verify all expectations were met
	assert.NoError(t, mockDB.ExpectationsWereMet())
}

func TestProductRepository_Update_NonDraftMenu(t *testing.T) {
	// Setup
	mockDB, err := testutil.NewMockDB()
	require.NoError(t, err)
	defer mockDB.Close()

	fixtures := testutil.NewTestFixtures()
	repo := NewProductRepository(mockDB.DB)

	newName := "Updated Pizza"
	req := &models.UpdateProductRequest{
		Name: &newName,
	}

	// Mock check menu status (menu is not in draft)
	mockDB.Mock.ExpectQuery(regexp.QuoteMeta("SELECT EXISTS( SELECT 1 FROM menu_products mp INNER JOIN menus m ON mp.menu_id = m.menu_id WHERE mp.product_id = $1 AND m.status != 'draft' )")).
		WithArgs(fixtures.ProductID1).
		WillReturnRows(sqlmock.NewRows([]string{"exists"}).AddRow(true))

	// Execute
	result, err := repo.Update(fixtures.ProductID1, req)

	// Assert
	assert.Error(t, err)
	assert.Nil(t, result)
	assert.Contains(t, err.Error(), "product cannot be updated: menu is not in draft status")

	// Verify all expectations were met
	assert.NoError(t, mockDB.ExpectationsWereMet())
}

func TestProductRepository_Update_WithAttributeGroups(t *testing.T) {
	// Setup
	mockDB, err := testutil.NewMockDB()
	require.NoError(t, err)
	defer mockDB.Close()

	fixtures := testutil.NewTestFixtures()
	repo := NewProductRepository(mockDB.DB)

	newName := "Updated Name"
	newAttributeGroups := []string{fixtures.AttributeGroup, fixtures.AttributeID1}
	req := &models.UpdateProductRequest{
		Name:              &newName,
		AttributeGroupIDs: newAttributeGroups,
	}

	// Mock check menu status
	mockDB.Mock.ExpectQuery(regexp.QuoteMeta("SELECT EXISTS( SELECT 1 FROM menu_products mp INNER JOIN menus m ON mp.menu_id = m.menu_id WHERE mp.product_id = $1 AND m.status != 'draft' )")).
		WithArgs(fixtures.ProductID1).
		WillReturnRows(sqlmock.NewRows([]string{"exists"}).AddRow(false))

	// Mock transaction
	mockDB.Mock.ExpectBegin()

	// Mock update product (with name field)
	mockDB.Mock.ExpectExec(regexp.QuoteMeta("UPDATE products SET name = $1 WHERE product_id = $2")).
		WithArgs(newName, fixtures.ProductID1).
		WillReturnResult(sqlmock.NewResult(0, 1))

	// Mock delete existing attribute groups
	mockDB.Mock.ExpectExec(regexp.QuoteMeta("DELETE FROM product_attribute_groups WHERE product_id = $1")).
		WithArgs(fixtures.ProductID1).
		WillReturnResult(sqlmock.NewResult(0, 1))

	// Mock insert new attribute groups
	for _, groupID := range newAttributeGroups {
		mockDB.Mock.ExpectExec(regexp.QuoteMeta("INSERT INTO product_attribute_groups (product_id, attribute_group_id) VALUES ($1, $2)")).
			WithArgs(fixtures.ProductID1, groupID).
			WillReturnResult(sqlmock.NewResult(1, 1))
	}

	mockDB.Mock.ExpectCommit()

	// Mock GetByID call after update
	mockDB.Mock.ExpectQuery(regexp.QuoteMeta("SELECT product_id, location_id, name, description, price, category, image_url, is_available, created_at, updated_at FROM products WHERE product_id = $1")).
		WithArgs(fixtures.ProductID1).
		WillReturnRows(sqlmock.NewRows([]string{
			"product_id", "location_id", "name", "description", "price", "category", "image_url", "is_available", "created_at", "updated_at",
		}).AddRow(
			fixtures.ProductID1, fixtures.LocationID, "Name", "Description",
			12.99, "Category", "url", true,
			time.Now(), time.Now(),
		))

	mockDB.Mock.ExpectQuery(regexp.QuoteMeta("SELECT attribute_group_id FROM product_attribute_groups WHERE product_id = $1")).
		WithArgs(fixtures.ProductID1).
		WillReturnRows(sqlmock.NewRows([]string{"attribute_group_id"}).
			AddRow(fixtures.AttributeGroup).
			AddRow(fixtures.AttributeID1))

	// Execute
	result, err := repo.Update(fixtures.ProductID1, req)

	// Assert
	require.NoError(t, err)
	assert.NotNil(t, result)
	assert.Len(t, result.AttributeGroupIDs, 2)

	// Verify all expectations were met
	assert.NoError(t, mockDB.ExpectationsWereMet())
}

func TestProductRepository_Delete_Success(t *testing.T) {
	// Setup
	mockDB, err := testutil.NewMockDB()
	require.NoError(t, err)
	defer mockDB.Close()

	fixtures := testutil.NewTestFixtures()
	repo := NewProductRepository(mockDB.DB)

	// Mock check menu status (menu is in draft)
	mockDB.Mock.ExpectQuery(regexp.QuoteMeta("SELECT EXISTS( SELECT 1 FROM menu_products mp INNER JOIN menus m ON mp.menu_id = m.menu_id WHERE mp.product_id = $1 AND m.status = 'draft' )")).
		WithArgs(fixtures.ProductID1).
		WillReturnRows(sqlmock.NewRows([]string{"exists"}).AddRow(true))

	// Mock delete product
	mockDB.Mock.ExpectExec(regexp.QuoteMeta("DELETE FROM products WHERE product_id = $1")).
		WithArgs(fixtures.ProductID1).
		WillReturnResult(sqlmock.NewResult(0, 1))

	// Execute
	err = repo.Delete(fixtures.ProductID1)

	// Assert
	assert.NoError(t, err)

	// Verify all expectations were met
	assert.NoError(t, mockDB.ExpectationsWereMet())
}

func TestProductRepository_Delete_NonDraftMenu(t *testing.T) {
	// Setup
	mockDB, err := testutil.NewMockDB()
	require.NoError(t, err)
	defer mockDB.Close()

	fixtures := testutil.NewTestFixtures()
	repo := NewProductRepository(mockDB.DB)

	// Mock check menu status (menu is not in draft)
	mockDB.Mock.ExpectQuery(regexp.QuoteMeta("SELECT EXISTS( SELECT 1 FROM menu_products mp INNER JOIN menus m ON mp.menu_id = m.menu_id WHERE mp.product_id = $1 AND m.status = 'draft' )")).
		WithArgs(fixtures.ProductID1).
		WillReturnRows(sqlmock.NewRows([]string{"exists"}).AddRow(false))

	// Execute
	err = repo.Delete(fixtures.ProductID1)

	// Assert
	assert.Error(t, err)
	assert.Contains(t, err.Error(), "product cannot be deleted: menu is not in draft status")

	// Verify all expectations were met
	assert.NoError(t, mockDB.ExpectationsWereMet())
}

func TestProductRepository_Delete_NotFound(t *testing.T) {
	// Setup
	mockDB, err := testutil.NewMockDB()
	require.NoError(t, err)
	defer mockDB.Close()

	fixtures := testutil.NewTestFixtures()
	repo := NewProductRepository(mockDB.DB)

	// Mock check menu status
	mockDB.Mock.ExpectQuery(regexp.QuoteMeta("SELECT EXISTS( SELECT 1 FROM menu_products mp INNER JOIN menus m ON mp.menu_id = m.menu_id WHERE mp.product_id = $1 AND m.status = 'draft' )")).
		WithArgs(fixtures.ProductID1).
		WillReturnRows(sqlmock.NewRows([]string{"exists"}).AddRow(true))

	// Mock delete product - no rows affected
	mockDB.Mock.ExpectExec(regexp.QuoteMeta("DELETE FROM products WHERE product_id = $1")).
		WithArgs(fixtures.ProductID1).
		WillReturnResult(sqlmock.NewResult(0, 0))

	// Execute
	err = repo.Delete(fixtures.ProductID1)

	// Assert
	assert.Error(t, err)
	assert.Contains(t, err.Error(), "product not found")

	// Verify all expectations were met
	assert.NoError(t, mockDB.ExpectationsWereMet())
}

func TestProductRepository_ToggleAvailability_Success(t *testing.T) {
	// Setup
	mockDB, err := testutil.NewMockDB()
	require.NoError(t, err)
	defer mockDB.Close()

	fixtures := testutil.NewTestFixtures()
	repo := NewProductRepository(mockDB.DB)

	// Mock toggle availability
	mockDB.Mock.ExpectExec(regexp.QuoteMeta("UPDATE products SET is_available = $1 WHERE product_id = $2")).
		WithArgs(false, fixtures.ProductID1).
		WillReturnResult(sqlmock.NewResult(0, 1))

	// Execute
	err = repo.ToggleAvailability(fixtures.ProductID1, false)

	// Assert
	assert.NoError(t, err)

	// Verify all expectations were met
	assert.NoError(t, mockDB.ExpectationsWereMet())
}

func TestProductRepository_ToggleAvailability_NotFound(t *testing.T) {
	// Setup
	mockDB, err := testutil.NewMockDB()
	require.NoError(t, err)
	defer mockDB.Close()

	fixtures := testutil.NewTestFixtures()
	repo := NewProductRepository(mockDB.DB)

	// Mock toggle availability - no rows affected
	mockDB.Mock.ExpectExec(regexp.QuoteMeta("UPDATE products SET is_available = $1 WHERE product_id = $2")).
		WithArgs(true, fixtures.ProductID1).
		WillReturnResult(sqlmock.NewResult(0, 0))

	// Execute
	err = repo.ToggleAvailability(fixtures.ProductID1, true)

	// Assert
	assert.Error(t, err)
	assert.Contains(t, err.Error(), "product not found")

	// Verify all expectations were met
	assert.NoError(t, mockDB.ExpectationsWereMet())
}
