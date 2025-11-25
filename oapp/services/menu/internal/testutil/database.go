package testutil

import (
	"database/sql"
	"fmt"
	"regexp"

	"github.com/DATA-DOG/go-sqlmock"
)

// MockDB wraps sqlmock for easier testing
type MockDB struct {
	DB   *sql.DB
	Mock sqlmock.Sqlmock
}

// NewMockDB creates a new mock database connection
func NewMockDB() (*MockDB, error) {
	db, mock, err := sqlmock.New()
	if err != nil {
		return nil, fmt.Errorf("failed to create mock db: %w", err)
	}

	return &MockDB{
		DB:   db,
		Mock: mock,
	}, nil
}

// Close closes the mock database
func (m *MockDB) Close() error {
	return m.DB.Close()
}

// ExpectationsWereMet checks if all expectations were met
func (m *MockDB) ExpectationsWereMet() error {
	return m.Mock.ExpectationsWereMet()
}

// MockMenuExistsQuery sets up expectation for menu exists query
func (m *MockDB) MockMenuExistsQuery(menuID string, exists bool) {
	query := regexp.QuoteMeta("SELECT EXISTS(SELECT 1 FROM menus WHERE menu_id = $1)")
	m.Mock.ExpectQuery(query).
		WithArgs(menuID).
		WillReturnRows(sqlmock.NewRows([]string{"exists"}).AddRow(exists))
}

// MockMenuCreateQuery sets up expectation for menu creation
func (m *MockDB) MockMenuCreateQuery(menuID, locationID, status string) {
	// Check if menu exists
	m.Mock.ExpectQuery(regexp.QuoteMeta("SELECT EXISTS(SELECT 1 FROM menus WHERE location_id = $1)")).
		WithArgs(locationID).
		WillReturnRows(sqlmock.NewRows([]string{"exists"}).AddRow(false))

	// Insert menu
	insertQuery := regexp.QuoteMeta(`INSERT INTO menus (menu_id, location_id, status) VALUES ($1, $2, $3) RETURNING created_at, updated_at`)
	m.Mock.ExpectQuery(insertQuery).
		WithArgs(menuID, locationID, status).
		WillReturnRows(sqlmock.NewRows([]string{"created_at", "updated_at"}).
			AddRow(AnyTime{}, AnyTime{}))
}

// MockMenuGetByIDQuery sets up expectation for getting menu by ID
func (m *MockDB) MockMenuGetByIDQuery(menuID, locationID, status string) {
	query := regexp.QuoteMeta(`SELECT menu_id, location_id, status, submitted_at, reviewed_at, rejection_reason, created_at, updated_at FROM menus WHERE menu_id = $1`)
	m.Mock.ExpectQuery(query).
		WithArgs(menuID).
		WillReturnRows(sqlmock.NewRows([]string{
			"menu_id", "location_id", "status", "submitted_at", "reviewed_at", "rejection_reason", "created_at", "updated_at",
		}).AddRow(menuID, locationID, status, nil, nil, nil, AnyTime{}, AnyTime{}))
}

// MockProductCreateQuery sets up expectation for product creation
func (m *MockDB) MockProductCreateQuery(productID, locationID, name string, price float64) {
	insertQuery := regexp.QuoteMeta(`INSERT INTO products (product_id, location_id, name, description, price, category, image_url) VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING created_at, updated_at`)
	m.Mock.ExpectQuery(insertQuery).
		WithArgs(productID, locationID, name, sqlmock.AnyArg(), price, sqlmock.AnyArg(), sqlmock.AnyArg()).
		WillReturnRows(sqlmock.NewRows([]string{"created_at", "updated_at"}).
			AddRow(AnyTime{}, AnyTime{}))
}

// MockTransactionBegin sets up expectation for beginning a transaction
func (m *MockDB) MockTransactionBegin() {
	m.Mock.ExpectBegin()
}

// MockTransactionCommit sets up expectation for committing a transaction
func (m *MockDB) MockTransactionCommit() {
	m.Mock.ExpectCommit()
}

// MockTransactionRollback sets up expectation for rolling back a transaction
func (m *MockDB) MockTransactionRollback() {
	m.Mock.ExpectRollback()
}

// AnyTime is a type that matches any time.Time value in sqlmock
type AnyTime struct{}

// Match satisfies sqlmock.Argument interface
func (a AnyTime) Match(v interface{}) bool {
	_, ok := v.(AnyTime)
	return ok
}
