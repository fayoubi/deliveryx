package repository

import (
	"database/sql"
	"regexp"
	"testing"
	"time"

	"github.com/DATA-DOG/go-sqlmock"
	"github.com/deliveryx/menu-service/internal/testutil"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestMenuRepository_Create_Success(t *testing.T) {
	// Setup
	mockDB, err := testutil.NewMockDB()
	require.NoError(t, err)
	defer mockDB.Close()

	fixtures := testutil.NewTestFixtures()
	repo := NewMenuRepository(mockDB.DB)

	// Mock: Check if menu exists for location (should not exist)
	mockDB.Mock.ExpectQuery(regexp.QuoteMeta("SELECT EXISTS(SELECT 1 FROM menus WHERE location_id = $1)")).
		WithArgs(fixtures.LocationID).
		WillReturnRows(sqlmock.NewRows([]string{"exists"}).AddRow(false))

	// Mock: Insert menu
	now := time.Now()
	mockDB.Mock.ExpectQuery(regexp.QuoteMeta("INSERT INTO menus (menu_id, location_id, status) VALUES ($1, $2, $3) RETURNING created_at, updated_at")).
		WithArgs(sqlmock.AnyArg(), fixtures.LocationID, "draft").
		WillReturnRows(sqlmock.NewRows([]string{"created_at", "updated_at"}).
			AddRow(now, now))

	// Execute
	result, err := repo.Create(fixtures.LocationID)

	// Assert
	require.NoError(t, err)
	assert.NotNil(t, result)
	assert.Equal(t, fixtures.LocationID, result.LocationID)
	assert.Equal(t, "draft", result.Status)
	assert.NotEmpty(t, result.MenuID)

	// Verify all expectations were met
	assert.NoError(t, mockDB.ExpectationsWereMet())
}

func TestMenuRepository_Create_AlreadyExists(t *testing.T) {
	// Setup
	mockDB, err := testutil.NewMockDB()
	require.NoError(t, err)
	defer mockDB.Close()

	fixtures := testutil.NewTestFixtures()
	repo := NewMenuRepository(mockDB.DB)

	// Mock: Check if menu exists for location (exists)
	mockDB.Mock.ExpectQuery(regexp.QuoteMeta("SELECT EXISTS(SELECT 1 FROM menus WHERE location_id = $1)")).
		WithArgs(fixtures.LocationID).
		WillReturnRows(sqlmock.NewRows([]string{"exists"}).AddRow(true))

	// Execute
	result, err := repo.Create(fixtures.LocationID)

	// Assert
	assert.Error(t, err)
	assert.Nil(t, result)
	assert.Contains(t, err.Error(), "menu already exists for this location")

	// Verify all expectations were met
	assert.NoError(t, mockDB.ExpectationsWereMet())
}

func TestMenuRepository_GetByID_Success(t *testing.T) {
	// Setup
	mockDB, err := testutil.NewMockDB()
	require.NoError(t, err)
	defer mockDB.Close()

	fixtures := testutil.NewTestFixtures()
	repo := NewMenuRepository(mockDB.DB)

	now := time.Now()

	// Mock: Get menu by ID
	mockDB.Mock.ExpectQuery(regexp.QuoteMeta("SELECT menu_id, location_id, status, submitted_at, reviewed_at, rejection_reason, created_at, updated_at FROM menus WHERE menu_id = $1")).
		WithArgs(fixtures.MenuID).
		WillReturnRows(sqlmock.NewRows([]string{
			"menu_id", "location_id", "status", "submitted_at", "reviewed_at", "rejection_reason", "created_at", "updated_at",
		}).AddRow(fixtures.MenuID, fixtures.LocationID, "draft", nil, nil, nil, now, now))

	// Execute
	result, err := repo.GetByID(fixtures.MenuID)

	// Assert
	require.NoError(t, err)
	assert.NotNil(t, result)
	assert.Equal(t, fixtures.MenuID, result.MenuID)
	assert.Equal(t, fixtures.LocationID, result.LocationID)
	assert.Equal(t, "draft", result.Status)
	assert.Nil(t, result.SubmittedAt)
	assert.Nil(t, result.ReviewedAt)
	assert.Nil(t, result.RejectionReason)

	// Verify all expectations were met
	assert.NoError(t, mockDB.ExpectationsWereMet())
}

func TestMenuRepository_GetByID_NotFound(t *testing.T) {
	// Setup
	mockDB, err := testutil.NewMockDB()
	require.NoError(t, err)
	defer mockDB.Close()

	fixtures := testutil.NewTestFixtures()
	repo := NewMenuRepository(mockDB.DB)

	// Mock: Get menu by ID - not found
	mockDB.Mock.ExpectQuery(regexp.QuoteMeta("SELECT menu_id, location_id, status, submitted_at, reviewed_at, rejection_reason, created_at, updated_at FROM menus WHERE menu_id = $1")).
		WithArgs(fixtures.MenuID).
		WillReturnError(sql.ErrNoRows)

	// Execute
	result, err := repo.GetByID(fixtures.MenuID)

	// Assert
	assert.Error(t, err)
	assert.Nil(t, result)
	assert.Contains(t, err.Error(), "menu not found")

	// Verify all expectations were met
	assert.NoError(t, mockDB.ExpectationsWereMet())
}

func TestMenuRepository_Submit_Success(t *testing.T) {
	// Setup
	mockDB, err := testutil.NewMockDB()
	require.NoError(t, err)
	defer mockDB.Close()

	fixtures := testutil.NewTestFixtures()
	repo := NewMenuRepository(mockDB.DB)

	// Mock: Check if menu has products
	mockDB.Mock.ExpectQuery(regexp.QuoteMeta("SELECT EXISTS( SELECT 1 FROM collections c INNER JOIN menu_products mp ON c.collection_id = mp.collection_id WHERE c.menu_id = $1 )")).
		WithArgs(fixtures.MenuID).
		WillReturnRows(sqlmock.NewRows([]string{"exists"}).AddRow(true))

	// Mock: Update menu status to pending_review
	mockDB.Mock.ExpectExec(regexp.QuoteMeta("UPDATE menus SET status = 'pending_review', submitted_at = $1 WHERE menu_id = $2 AND status = 'draft'")).
		WithArgs(sqlmock.AnyArg(), fixtures.MenuID).
		WillReturnResult(sqlmock.NewResult(0, 1))

	// Execute
	err = repo.Submit(fixtures.MenuID)

	// Assert
	assert.NoError(t, err)

	// Verify all expectations were met
	assert.NoError(t, mockDB.ExpectationsWereMet())
}

func TestMenuRepository_Submit_NoProducts(t *testing.T) {
	// Setup
	mockDB, err := testutil.NewMockDB()
	require.NoError(t, err)
	defer mockDB.Close()

	fixtures := testutil.NewTestFixtures()
	repo := NewMenuRepository(mockDB.DB)

	// Mock: Check if menu has products (no products)
	mockDB.Mock.ExpectQuery(regexp.QuoteMeta("SELECT EXISTS( SELECT 1 FROM collections c INNER JOIN menu_products mp ON c.collection_id = mp.collection_id WHERE c.menu_id = $1 )")).
		WithArgs(fixtures.MenuID).
		WillReturnRows(sqlmock.NewRows([]string{"exists"}).AddRow(false))

	// Execute
	err = repo.Submit(fixtures.MenuID)

	// Assert
	assert.Error(t, err)
	assert.Contains(t, err.Error(), "menu must have at least 1 collection with at least 1 product")

	// Verify all expectations were met
	assert.NoError(t, mockDB.ExpectationsWereMet())
}

func TestMenuRepository_Submit_NotDraftStatus(t *testing.T) {
	// Setup
	mockDB, err := testutil.NewMockDB()
	require.NoError(t, err)
	defer mockDB.Close()

	fixtures := testutil.NewTestFixtures()
	repo := NewMenuRepository(mockDB.DB)

	// Mock: Check if menu has products
	mockDB.Mock.ExpectQuery(regexp.QuoteMeta("SELECT EXISTS( SELECT 1 FROM collections c INNER JOIN menu_products mp ON c.collection_id = mp.collection_id WHERE c.menu_id = $1 )")).
		WithArgs(fixtures.MenuID).
		WillReturnRows(sqlmock.NewRows([]string{"exists"}).AddRow(true))

	// Mock: Update menu status - no rows affected (menu not in draft status)
	mockDB.Mock.ExpectExec(regexp.QuoteMeta("UPDATE menus SET status = 'pending_review', submitted_at = $1 WHERE menu_id = $2 AND status = 'draft'")).
		WithArgs(sqlmock.AnyArg(), fixtures.MenuID).
		WillReturnResult(sqlmock.NewResult(0, 0))

	// Execute
	err = repo.Submit(fixtures.MenuID)

	// Assert
	assert.Error(t, err)
	assert.Contains(t, err.Error(), "menu not found or not in draft status")

	// Verify all expectations were met
	assert.NoError(t, mockDB.ExpectationsWereMet())
}

func TestMenuRepository_UpdateStatus_Success(t *testing.T) {
	// Setup
	mockDB, err := testutil.NewMockDB()
	require.NoError(t, err)
	defer mockDB.Close()

	fixtures := testutil.NewTestFixtures()
	repo := NewMenuRepository(mockDB.DB)

	rejectionReason := "Menu needs more items"

	// Mock: Update menu status
	mockDB.Mock.ExpectExec(regexp.QuoteMeta("UPDATE menus SET status = $1, reviewed_at = $2, rejection_reason = $3 WHERE menu_id = $4")).
		WithArgs("rejected", sqlmock.AnyArg(), &rejectionReason, fixtures.MenuID).
		WillReturnResult(sqlmock.NewResult(0, 1))

	// Execute
	err = repo.UpdateStatus(fixtures.MenuID, "rejected", &rejectionReason)

	// Assert
	assert.NoError(t, err)

	// Verify all expectations were met
	assert.NoError(t, mockDB.ExpectationsWereMet())
}

func TestMenuRepository_UpdateStatus_Approved(t *testing.T) {
	// Setup
	mockDB, err := testutil.NewMockDB()
	require.NoError(t, err)
	defer mockDB.Close()

	fixtures := testutil.NewTestFixtures()
	repo := NewMenuRepository(mockDB.DB)

	// Mock: Update menu status to approved (no rejection reason)
	mockDB.Mock.ExpectExec(regexp.QuoteMeta("UPDATE menus SET status = $1, reviewed_at = $2, rejection_reason = $3 WHERE menu_id = $4")).
		WithArgs("approved", sqlmock.AnyArg(), nil, fixtures.MenuID).
		WillReturnResult(sqlmock.NewResult(0, 1))

	// Execute
	err = repo.UpdateStatus(fixtures.MenuID, "approved", nil)

	// Assert
	assert.NoError(t, err)

	// Verify all expectations were met
	assert.NoError(t, mockDB.ExpectationsWereMet())
}

func TestMenuRepository_UpdateStatus_NotFound(t *testing.T) {
	// Setup
	mockDB, err := testutil.NewMockDB()
	require.NoError(t, err)
	defer mockDB.Close()

	fixtures := testutil.NewTestFixtures()
	repo := NewMenuRepository(mockDB.DB)

	// Mock: Update menu status - no rows affected
	mockDB.Mock.ExpectExec(regexp.QuoteMeta("UPDATE menus SET status = $1, reviewed_at = $2, rejection_reason = $3 WHERE menu_id = $4")).
		WithArgs("approved", sqlmock.AnyArg(), nil, fixtures.MenuID).
		WillReturnResult(sqlmock.NewResult(0, 0))

	// Execute
	err = repo.UpdateStatus(fixtures.MenuID, "approved", nil)

	// Assert
	assert.Error(t, err)
	assert.Contains(t, err.Error(), "menu not found")

	// Verify all expectations were met
	assert.NoError(t, mockDB.ExpectationsWereMet())
}

func TestMenuRepository_CountByLocation_Success(t *testing.T) {
	// Setup
	mockDB, err := testutil.NewMockDB()
	require.NoError(t, err)
	defer mockDB.Close()

	fixtures := testutil.NewTestFixtures()
	repo := NewMenuRepository(mockDB.DB)

	// Mock: Count menus by location
	mockDB.Mock.ExpectQuery(regexp.QuoteMeta("SELECT COUNT(*) FROM menus WHERE location_id = $1")).
		WithArgs(fixtures.LocationID).
		WillReturnRows(sqlmock.NewRows([]string{"count"}).AddRow(1))

	// Execute
	count, err := repo.CountByLocation(fixtures.LocationID)

	// Assert
	assert.NoError(t, err)
	assert.Equal(t, 1, count)

	// Verify all expectations were met
	assert.NoError(t, mockDB.ExpectationsWereMet())
}

func TestMenuRepository_GetSummaryByLocation_Success(t *testing.T) {
	// Setup
	mockDB, err := testutil.NewMockDB()
	require.NoError(t, err)
	defer mockDB.Close()

	fixtures := testutil.NewTestFixtures()
	repo := NewMenuRepository(mockDB.DB)

	// Mock: Get menu by location
	mockDB.Mock.ExpectQuery(regexp.QuoteMeta("SELECT menu_id, status FROM menus WHERE location_id = $1")).
		WithArgs(fixtures.LocationID).
		WillReturnRows(sqlmock.NewRows([]string{"menu_id", "status"}).
			AddRow(fixtures.MenuID, "approved"))

	// Mock: Count collections
	mockDB.Mock.ExpectQuery(regexp.QuoteMeta("SELECT COUNT(*) FROM collections WHERE menu_id = $1")).
		WithArgs(fixtures.MenuID).
		WillReturnRows(sqlmock.NewRows([]string{"count"}).AddRow(3))

	// Mock: Count products
	mockDB.Mock.ExpectQuery(regexp.QuoteMeta("SELECT COUNT(DISTINCT mp.product_id) FROM menu_products mp JOIN collections c ON mp.collection_id = c.collection_id WHERE c.menu_id = $1")).
		WithArgs(fixtures.MenuID).
		WillReturnRows(sqlmock.NewRows([]string{"count"}).AddRow(15))

	// Execute
	summary, err := repo.GetSummaryByLocation(fixtures.LocationID)

	// Assert
	require.NoError(t, err)
	assert.NotNil(t, summary)
	assert.Equal(t, fixtures.MenuID, summary.MenuID)
	assert.Equal(t, "approved", summary.Status)
	assert.Equal(t, 3, summary.CollectionsCount)
	assert.Equal(t, 15, summary.ProductsCount)

	// Verify all expectations were met
	assert.NoError(t, mockDB.ExpectationsWereMet())
}

func TestMenuRepository_GetSummaryByLocation_NoMenu(t *testing.T) {
	// Setup
	mockDB, err := testutil.NewMockDB()
	require.NoError(t, err)
	defer mockDB.Close()

	fixtures := testutil.NewTestFixtures()
	repo := NewMenuRepository(mockDB.DB)

	// Mock: Get menu by location - no menu found
	mockDB.Mock.ExpectQuery(regexp.QuoteMeta("SELECT menu_id, status FROM menus WHERE location_id = $1")).
		WithArgs(fixtures.LocationID).
		WillReturnError(sql.ErrNoRows)

	// Execute
	summary, err := repo.GetSummaryByLocation(fixtures.LocationID)

	// Assert
	assert.NoError(t, err)
	assert.Nil(t, summary)

	// Verify all expectations were met
	assert.NoError(t, mockDB.ExpectationsWereMet())
}
