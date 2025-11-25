# Menu Service Testing Guide

This document provides comprehensive guidance on testing the Menu Service.

## Table of Contents
- [Overview](#overview)
- [Running Tests](#running-tests)
- [Test Structure](#test-structure)
- [Writing Tests](#writing-tests)
- [Test Coverage](#test-coverage)
- [Best Practices](#best-practices)

## Overview

The Menu Service uses the following testing framework:
- **Testing Framework**: Go's built-in `testing` package
- **Assertions**: `stretchr/testify/assert` and `stretchr/testify/require`
- **Mocking**: `stretchr/testify/mock` for behavior mocking
- **Database Mocking**: `DATA-DOG/go-sqlmock` for SQL query mocking

### Test Coverage

Current test coverage for repository layer:
- ✅ **MenuRepository**: Full coverage (Create, GetByID, Submit, UpdateStatus, CountByLocation, GetSummaryByLocation)
- ✅ **MenuRetrievalRepository**: Full coverage (GetCompleteMenu and all helper methods)
- ✅ **ProductRepository**: Full coverage (Create, GetByID, Update, Delete, ToggleAvailability)

### What's Tested
- Repository layer (database interactions)
- Business logic and validation
- Error handling
- Edge cases and boundary conditions

### What's Not Tested (Future Work)
- Handler layer (HTTP request/response handling)
- Integration tests with real database
- End-to-end API tests

## Running Tests

### Quick Start

From the **oapp/** directory (parent of services/menu):

```bash
# Run all menu service tests
make test-menu

# Run with coverage report
make test-coverage

# Generate HTML coverage report
make test-coverage-html
```

### From Menu Service Directory

```bash
cd services/menu

# Run all tests
go test ./...

# Run tests with verbose output
go test ./... -v

# Run specific test
go test ./internal/repository -run TestMenuRepository_Create_Success -v

# Run tests with coverage
go test ./... -coverprofile=coverage.out

# View coverage in terminal
go tool cover -func=coverage.out

# Generate HTML coverage report
go tool cover -html=coverage.out -o coverage.html
open coverage.html  # macOS
```

### Run Specific Package Tests

```bash
# Test only repository layer
go test ./internal/repository/... -v

# Test only menu repository
go test ./internal/repository -run TestMenuRepository -v

# Test only product repository
go test ./internal/repository -run TestProductRepository -v
```

## Test Structure

### Directory Layout

```
services/menu/
├── internal/
│   ├── repository/
│   │   ├── menu_repository.go
│   │   ├── menu_repository_test.go            # ← Tests for MenuRepository
│   │   ├── menu_retrieval_repository.go
│   │   ├── menu_retrieval_repository_test.go  # ← Tests for MenuRetrievalRepository
│   │   ├── product_repository.go
│   │   └── product_repository_test.go         # ← Tests for ProductRepository
│   └── testutil/
│       ├── fixtures.go         # ← Reusable test data fixtures
│       └── database.go         # ← Database mocking utilities
└── go.mod
```

### Test File Naming Convention

- Test files MUST end with `_test.go`
- Test files MUST be in the same package as the code being tested
- Test function names MUST start with `Test`

Example:
```go
// menu_repository_test.go
package repository

func TestMenuRepository_Create_Success(t *testing.T) { ... }
func TestMenuRepository_Create_AlreadyExists(t *testing.T) { ... }
```

## Writing Tests

### Test Naming Convention

Follow this pattern: `Test<StructName>_<MethodName>_<Scenario>`

Examples:
- `TestMenuRepository_Create_Success` - Happy path
- `TestMenuRepository_Create_AlreadyExists` - Error case
- `TestProductRepository_Update_NonDraftMenu` - Validation error

### Test Anatomy

Every test should follow this structure:

```go
func TestSomething_Scenario(t *testing.T) {
    // 1. Setup - Create mocks and fixtures
    mockDB, err := testutil.NewMockDB()
    require.NoError(t, err)
    defer mockDB.Close()

    fixtures := testutil.NewTestFixtures()
    repo := NewSomeRepository(mockDB.DB)

    // 2. Setup Expectations - Define what the mock should expect
    mockDB.Mock.ExpectQuery(...)
        .WithArgs(...)
        .WillReturnRows(...)

    // 3. Execute - Call the method being tested
    result, err := repo.SomeMethod(fixtures.SomeID)

    // 4. Assert - Verify the results
    require.NoError(t, err)
    assert.NotNil(t, result)
    assert.Equal(t, expected, result.Field)

    // 5. Verify - Ensure all mock expectations were met
    assert.NoError(t, mockDB.ExpectationsWereMet())
}
```

### Using Test Fixtures

The `testutil` package provides reusable test fixtures:

```go
// Create fixtures with generated UUIDs
fixtures := testutil.NewTestFixtures()

// Use pre-generated IDs
menuID := fixtures.MenuID
locationID := fixtures.LocationID
productID := fixtures.ProductID1

// Create test models
menu := fixtures.CreateTestMenu("draft")
product := fixtures.CreateTestProduct("Pizza", 12.99)
collection := fixtures.CreateTestCollection("Main Dishes", 1)
```

### Mocking Database Queries

#### Simple Query

```go
mockDB.Mock.ExpectQuery(regexp.QuoteMeta("SELECT * FROM menus WHERE menu_id = $1")).
    WithArgs(menuID).
    WillReturnRows(sqlmock.NewRows([]string{"menu_id", "status"}).
        AddRow(menuID, "draft"))
```

#### Query with Multiple Rows

```go
mockDB.Mock.ExpectQuery(regexp.QuoteMeta("SELECT id, name FROM products")).
    WillReturnRows(sqlmock.NewRows([]string{"id", "name"}).
        AddRow(productID1, "Pizza").
        AddRow(productID2, "Burger"))
```

#### Exec (INSERT/UPDATE/DELETE)

```go
mockDB.Mock.ExpectExec(regexp.QuoteMeta("UPDATE menus SET status = $1 WHERE menu_id = $2")).
    WithArgs("approved", menuID).
    WillReturnResult(sqlmock.NewResult(0, 1))  // (lastInsertId, rowsAffected)
```

#### Transaction

```go
mockDB.Mock.ExpectBegin()
mockDB.Mock.ExpectQuery(...)
mockDB.Mock.ExpectExec(...)
mockDB.Mock.ExpectCommit()
```

### Testing Error Cases

Always test both success and failure scenarios:

```go
// Success case
func TestMenuRepository_GetByID_Success(t *testing.T) { ... }

// Not found case
func TestMenuRepository_GetByID_NotFound(t *testing.T) {
    mockDB.Mock.ExpectQuery(...).WillReturnError(sql.ErrNoRows)

    result, err := repo.GetByID(menuID)

    assert.Error(t, err)
    assert.Nil(t, result)
    assert.Contains(t, err.Error(), "menu not found")
}

// Database error case
func TestMenuRepository_GetByID_DatabaseError(t *testing.T) {
    mockDB.Mock.ExpectQuery(...).WillReturnError(sql.ErrConnDone)

    result, err := repo.GetByID(menuID)

    assert.Error(t, err)
    assert.Nil(t, result)
}
```

## Test Coverage

### Viewing Coverage

```bash
# Terminal view
go test ./... -coverprofile=coverage.out
go tool cover -func=coverage.out

# HTML view (recommended)
go tool cover -html=coverage.out -o coverage.html
open coverage.html
```

### Coverage Goals

- **Repository Layer**: Target 80%+ coverage
- **Critical Business Logic**: Target 90%+ coverage
- **Handler Layer**: Target 70%+ coverage (future work)

### Coverage Report Example

```
github.com/deliveryx/menu-service/internal/repository/menu_repository.go:21:        Create                  100.0%
github.com/deliveryx/menu-service/internal/repository/menu_repository.go:54:        GetByID                 100.0%
github.com/deliveryx/menu-service/internal/repository/menu_repository.go:86:        Submit                  100.0%
github.com/deliveryx/menu-service/internal/repository/menu_repository.go:128:       UpdateStatus            100.0%
total:                                                                               (statements)            85.2%
```

## Best Practices

### DO ✅

1. **Write Tests First** (TDD when possible)
   - Define expected behavior before implementation
   - Helps clarify requirements

2. **Test One Thing Per Test**
   ```go
   // Good - focused test
   func TestMenuRepository_Create_Success(t *testing.T) { ... }
   func TestMenuRepository_Create_AlreadyExists(t *testing.T) { ... }

   // Bad - testing multiple scenarios in one test
   func TestMenuRepository_Create(t *testing.T) {
       // tests success, failure, validation all together
   }
   ```

3. **Use Descriptive Test Names**
   - Name should describe what's being tested and expected outcome
   - Good: `TestProductRepository_Update_NonDraftMenu`
   - Bad: `TestUpdate`, `TestUpdate2`

4. **Use Table-Driven Tests** for similar test cases
   ```go
   func TestValidation(t *testing.T) {
       tests := []struct {
           name    string
           input   string
           wantErr bool
       }{
           {"valid", "test@example.com", false},
           {"invalid", "not-an-email", true},
           {"empty", "", true},
       }

       for _, tt := range tests {
           t.Run(tt.name, func(t *testing.T) {
               err := Validate(tt.input)
               if tt.wantErr {
                   assert.Error(t, err)
               } else {
                   assert.NoError(t, err)
               }
           })
       }
   }
   ```

5. **Always Check Mock Expectations**
   ```go
   assert.NoError(t, mockDB.ExpectationsWereMet())
   ```

6. **Use `require` for Critical Assertions**
   ```go
   require.NoError(t, err)  // Stops test immediately if fails
   assert.Equal(t, expected, actual)  // Continues even if fails
   ```

### DON'T ❌

1. **Don't Test Implementation Details**
   - Test behavior, not internal structure
   - Bad: Testing that method X calls method Y
   - Good: Testing that the result is correct

2. **Don't Use Real Database in Unit Tests**
   - Use sqlmock for repository tests
   - Save integration tests for separate test suite

3. **Don't Ignore Test Failures**
   - Fix or update tests immediately
   - Broken tests are worse than no tests

4. **Don't Skip Cleanup**
   ```go
   defer mockDB.Close()  // Always clean up resources
   ```

5. **Don't Test Third-Party Libraries**
   - Trust that `database/sql`, `gorilla/mux`, etc. work
   - Test your code's usage of them

### Common Patterns

#### Testing Repository Methods

```go
func TestRepository_MethodName_Scenario(t *testing.T) {
    // Setup mock
    mockDB, err := testutil.NewMockDB()
    require.NoError(t, err)
    defer mockDB.Close()

    fixtures := testutil.NewTestFixtures()
    repo := NewRepository(mockDB.DB)

    // Setup expectations
    mockDB.Mock.ExpectQuery(...).WillReturnRows(...)

    // Execute
    result, err := repo.MethodName(fixtures.ID)

    // Assert
    require.NoError(t, err)
    assert.NotNil(t, result)
    assert.NoError(t, mockDB.ExpectationsWereMet())
}
```

#### Testing Validation Logic

```go
func TestRepository_Update_ValidationError(t *testing.T) {
    mockDB, _ := testutil.NewMockDB()
    defer mockDB.Close()

    repo := NewRepository(mockDB.DB)

    // No mock expectations needed - should fail validation before DB call

    req := &InvalidRequest{}
    result, err := repo.Update(id, req)

    assert.Error(t, err)
    assert.Nil(t, result)
    assert.Contains(t, err.Error(), "validation")
}
```

## Troubleshooting

### Common Issues

#### 1. "all expectations were already fulfilled"

This means your test called more database methods than you set up expectations for.

**Solution**: Add missing expectations or check your test logic.

#### 2. "call to Query was not expected"

The code is making a database call you didn't mock.

**Solution**: Add the missing `ExpectQuery` or `ExpectExec`.

#### 3. "could not match actual sql"

The SQL query doesn't match your expectation (usually whitespace/formatting).

**Solution**: Use `regexp.QuoteMeta()` to escape special characters:
```go
mockDB.Mock.ExpectQuery(regexp.QuoteMeta("SELECT * FROM menus"))
```

#### 4. Tests pass locally but fail in CI

**Solution**: Ensure tests don't depend on local state, time, or random data.

## Future Improvements

### Planned Test Additions

1. **Handler Tests** (requires interface refactoring)
   - HTTP request/response testing
   - Middleware testing
   - Error response formatting

2. **Integration Tests**
   - Test with real PostgreSQL (using testcontainers)
   - Test service-to-service communication
   - Test RabbitMQ event publishing/consuming

3. **E2E Tests**
   - Full API workflow tests
   - Test complete user journeys
   - Test with real infrastructure

### Test Infrastructure Improvements

1. Add test helper for common assertions
2. Add performance/benchmark tests
3. Add mutation testing
4. Integrate with CI/CD pipeline

## Resources

- [Go Testing Package](https://golang.org/pkg/testing/)
- [Testify Documentation](https://github.com/stretchr/testify)
- [Go-SQLMock Documentation](https://github.com/DATA-DOG/go-sqlmock)
- [Table Driven Tests](https://github.com/golang/go/wiki/TableDrivenTests)

---

Last Updated: 2025-01-21
