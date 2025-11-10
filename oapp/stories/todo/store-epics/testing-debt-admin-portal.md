## Epic: Admin-Portal Testing Debt ##

**Story:** Automated Testing for Admin Portal Frontend
**Story Type:** Technical Debt / Quality
**Priority:** Medium
**Depends On:** `web-ui-story1.md` (Admin Portal MVP must be completed first)

---

## User Story

As a developer
I want comprehensive automated tests for the Admin Portal frontend
So that I can refactor confidently, catch regressions early, and ensure code quality as the application grows.

---

## Context & Background

The Admin Portal MVP (`web-ui-story1.md`) was implemented without automated frontend tests due to time constraints. While the backend API has comprehensive test coverage and manual testing was performed, the frontend lacks:

- Unit tests for components and utilities
- Integration tests for form submissions and API interactions
- End-to-end tests for user workflows
- Visual regression tests for responsive layouts

**Current State:**
- Admin Portal fully functional and manually tested
- Backend API has 95+ test assertions passing via Postman
- No automated frontend tests
- Refactoring and future changes carry higher risk

**Desired State:**
- High test coverage for critical user flows
- Automated test suite running in CI/CD pipeline
- Confidence to refactor and extend features safely

---

## Technical Stack

### Testing Framework & Tools

- **Unit Testing**: Vitest (Vite-native test runner)
- **Component Testing**: React Testing Library
- **E2E Testing**: Playwright
- **Assertions**: expect (Vitest) + Testing Library matchers
- **Mocking**: MSW (Mock Service Worker) for API mocking
- **Visual Regression**: Playwright screenshots + Argos CI (optional)

### Why These Tools?

- **Vitest**: Fast, Vite-native, compatible with Jest syntax
- **React Testing Library**: Encourages testing user behavior over implementation details
- **Playwright**: Modern, reliable, supports multiple browsers, great debugging
- **MSW**: Intercepts network requests at the service worker level, more realistic than axios mocks

---

## Acceptance Criteria

### AC1: Test Infrastructure Setup

- ✅ Vitest configured in `vite.config.js`
- ✅ React Testing Library installed and configured
- ✅ Playwright installed and configured with `playwright.config.js`
- ✅ MSW installed and configured with test handlers
- ✅ Test scripts added to `package.json`:
  - `npm run test` – run unit tests
  - `npm run test:watch` – run unit tests in watch mode
  - `npm run test:e2e` – run E2E tests
  - `npm run test:coverage` – generate coverage report
- ✅ Coverage thresholds configured (minimum 70% for critical paths)

---

### AC2: Unit Tests for Components

**Target Coverage**: 80%+ for components

- ✅ **Button.jsx**
  - Renders with correct text
  - Handles click events
  - Shows loading state correctly
  - Applies variant styles (primary, secondary, danger)

- ✅ **Modal.jsx**
  - Opens and closes on prop changes
  - Closes on ESC key
  - Closes on outside click
  - Traps focus within modal

- ✅ **ConfirmDialog.jsx**
  - Renders warning message correctly
  - Calls onConfirm when confirmed
  - Calls onCancel when cancelled

- ✅ **StoreCard.jsx / StoreTable.jsx**
  - Renders store data correctly
  - Action buttons trigger correct callbacks
  - Handles empty state

- ✅ **LocationCard.jsx / LocationTable.jsx**
  - Renders location data correctly
  - Action buttons trigger correct callbacks
  - Handles empty state

---

### AC3: Unit Tests for Utilities

**Target Coverage**: 90%+

- ✅ **validation.js**
  - URL format validation (http/https)
  - Phone number validation (regex matching)
  - Latitude/longitude range validation
  - Field length validation

---

### AC4: Integration Tests for Pages

**Target Coverage**: Key user flows

- ✅ **StoresList.jsx**
  - Fetches and displays stores on load
  - Shows loading spinner while fetching
  - Shows empty state when no stores
  - Opens create modal on button click
  - Opens edit modal on edit button click
  - Opens delete dialog on delete button click
  - Handles API errors gracefully

- ✅ **StoreDetails.jsx**
  - Fetches and displays store details
  - Fetches and displays locations for store
  - Opens edit store modal
  - Opens create location modal
  - Opens edit location modal
  - Opens delete location dialog
  - Navigates back to stores list

---

### AC5: Integration Tests for Forms

**Target Coverage**: All CRUD operations with MSW mocking

- ✅ **Create Store Form**
  - Validates required fields
  - Validates logo URL format
  - Validates phone number format
  - Submits valid data successfully
  - Shows success toast on success
  - Shows error toast on API error
  - Updates store list optimistically
  - Rolls back on API error

- ✅ **Edit Store Form**
  - Pre-populates form with existing data
  - Submits updated data successfully
  - Updates store in list optimistically
  - Rolls back on API error

- ✅ **Delete Store**
  - Shows confirmation dialog
  - Submits delete request on confirm
  - Removes store from list optimistically
  - Handles 409 Conflict error (store has locations)
  - Shows error message and keeps store in list

- ✅ **Create/Edit/Delete Location Forms**
  - Same coverage as store forms
  - Validates optional fields (postal code, manager, lat/lng)
  - Handles location-specific validations

---

### AC6: E2E Tests with Playwright

**Target Coverage**: Critical user journeys

- ✅ **Happy Path: Complete Store & Location CRUD**
  - Navigate to admin portal
  - Create a new store
  - Verify store appears in list
  - Click on store to view details
  - Add a location to store
  - Edit location
  - Delete location
  - Navigate back to stores list
  - Delete store
  - Verify store removed from list

- ✅ **Error Handling: Delete Conflicts**
  - Create store with location
  - Attempt to delete store (should fail with 409)
  - Verify error message displayed
  - Delete location first
  - Delete store successfully

- ✅ **Error Handling: Network Errors**
  - Simulate network failure
  - Verify error toast displayed
  - Verify graceful fallback behavior

- ✅ **Mobile Responsiveness**
  - Run tests on mobile viewport (375px)
  - Verify card layouts display correctly
  - Verify modals are full-screen
  - Verify touch targets are appropriately sized

---

### AC7: API Mocking with MSW

- ✅ MSW handlers created for all API endpoints:
  - `GET /api/v1/stores`
  - `POST /api/v1/stores`
  - `GET /api/v1/stores/{store_id}`
  - `PUT /api/v1/stores/{store_id}`
  - `DELETE /api/v1/stores/{store_id}`
  - `GET /api/v1/stores/{store_id}/locations`
  - `POST /api/v1/stores/{store_id}/locations`
  - `PUT /api/v1/locations/{location_id}`
  - `DELETE /api/v1/locations/{location_id}`
- ✅ Handlers simulate:
  - Success responses (200, 201, 204)
  - Error responses (400, 404, 409, 500)
  - Network delays
- ✅ Handlers maintain in-memory state for realistic CRUD behavior

---

### AC8: Test Coverage Report

- ✅ Generate coverage report with `npm run test:coverage`
- ✅ Coverage thresholds:
  - **Statements**: 70%+
  - **Branches**: 70%+
  - **Functions**: 70%+
  - **Lines**: 70%+
- ✅ Exclude non-critical files from coverage requirements:
  - `src/main.jsx`
  - `vite.config.js`
  - `tailwind.config.js`

---

### AC9: CI/CD Integration (Optional but Recommended)

- ✅ Add test step to GitHub Actions workflow
- ✅ Run unit tests on every PR
- ✅ Run E2E tests on every merge to main
- ✅ Block merges if tests fail
- ✅ Upload coverage report to Codecov or similar service

---

## Test File Structure

```text
admin-portal/
├── src/
│   ├── components/
│   │   ├── Button.jsx
│   │   ├── Button.test.jsx          # Unit tests for Button
│   │   ├── Modal.jsx
│   │   ├── Modal.test.jsx           # Unit tests for Modal
│   │   ├── ConfirmDialog.test.jsx
│   │   ├── StoreCard.test.jsx
│   │   ├── StoreTable.test.jsx
│   │   ├── LocationCard.test.jsx
│   │   └── LocationTable.test.jsx
│   ├── pages/
│   │   ├── StoresList.jsx
│   │   ├── StoresList.test.jsx      # Integration tests
│   │   ├── StoreDetails.jsx
│   │   └── StoreDetails.test.jsx    # Integration tests
│   ├── utils/
│   │   ├── validation.js
│   │   └── validation.test.js       # Unit tests for validation
│   └── services/
│       └── api.test.js              # Unit tests for API service
├── tests/
│   ├── mocks/
│   │   ├── handlers.js              # MSW API handlers
│   │   └── server.js                # MSW server setup
│   ├── e2e/
│   │   ├── stores.spec.js           # E2E tests for stores
│   │   └── locations.spec.js        # E2E tests for locations
│   └── setup.js                     # Test setup (MSW, global mocks)
├── playwright.config.js
└── vitest.config.js
```

---

## Example Test Cases

### Example 1: Unit Test for Button Component

```jsx
import { render, screen, fireEvent } from '@testing-library/react';
import { describe, it, expect, vi } from 'vitest';
import Button from './Button';

describe('Button', () => {
  it('renders with correct text', () => {
    render(<Button>Click me</Button>);
    expect(screen.getByText('Click me')).toBeInTheDocument();
  });

  it('handles click events', () => {
    const handleClick = vi.fn();
    render(<Button onClick={handleClick}>Click me</Button>);
    fireEvent.click(screen.getByText('Click me'));
    expect(handleClick).toHaveBeenCalledTimes(1);
  });

  it('shows loading state', () => {
    render(<Button loading>Click me</Button>);
    expect(screen.getByRole('button')).toBeDisabled();
    expect(screen.getByText('Loading...')).toBeInTheDocument(); // or spinner
  });

  it('applies danger variant style', () => {
    render(<Button variant="danger">Delete</Button>);
    expect(screen.getByRole('button')).toHaveClass('bg-red-600');
  });
});
```

---

### Example 2: Integration Test for Create Store Form

```jsx
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { describe, it, expect, beforeAll, afterEach, afterAll } from 'vitest';
import { setupServer } from 'msw/node';
import { http, HttpResponse } from 'msw';
import StoresList from './StoresList';

const server = setupServer(
  http.post('/api/v1/stores', async ({ request }) => {
    const body = await request.json();
    return HttpResponse.json(
      { id: '123', ...body, created_at: new Date().toISOString() },
      { status: 201 }
    );
  })
);

beforeAll(() => server.listen());
afterEach(() => server.resetHandlers());
afterAll(() => server.close());

describe('Create Store Form', () => {
  it('creates a store successfully', async () => {
    render(<StoresList />);

    // Open create modal
    fireEvent.click(screen.getByText('Create Store'));

    // Fill form
    fireEvent.change(screen.getByLabelText('Name'), {
      target: { value: 'Test Store' }
    });
    fireEvent.change(screen.getByLabelText('Description'), {
      target: { value: 'Test Description' }
    });
    fireEvent.change(screen.getByLabelText('Phone'), {
      target: { value: '+1-555-1234' }
    });

    // Submit
    fireEvent.click(screen.getByText('Create Store'));

    // Verify success
    await waitFor(() => {
      expect(screen.getByText('Store created successfully')).toBeInTheDocument();
      expect(screen.getByText('Test Store')).toBeInTheDocument();
    });
  });

  it('handles API errors gracefully', async () => {
    server.use(
      http.post('/api/v1/stores', () => {
        return HttpResponse.json(
          { message: 'Database error', code: 'INTERNAL_ERROR' },
          { status: 500 }
        );
      })
    );

    render(<StoresList />);

    // Fill and submit form
    fireEvent.click(screen.getByText('Create Store'));
    fireEvent.change(screen.getByLabelText('Name'), {
      target: { value: 'Test Store' }
    });
    fireEvent.change(screen.getByLabelText('Description'), {
      target: { value: 'Test Description' }
    });
    fireEvent.change(screen.getByLabelText('Phone'), {
      target: { value: '+1-555-1234' }
    });
    fireEvent.click(screen.getByText('Create Store'));

    // Verify error handling
    await waitFor(() => {
      expect(screen.getByText('Database error')).toBeInTheDocument();
      expect(screen.queryByText('Test Store')).not.toBeInTheDocument(); // Rolled back
    });
  });
});
```

---

### Example 3: E2E Test with Playwright

```javascript
import { test, expect } from '@playwright/test';

test.describe('Store Management', () => {
  test('complete CRUD flow', async ({ page }) => {
    // Navigate to admin portal
    await page.goto('http://localhost/admin');

    // Create store
    await page.click('text=Create Store');
    await page.fill('input[name="name"]', 'E2E Test Store');
    await page.fill('textarea[name="description"]', 'Created by E2E test');
    await page.fill('input[name="phone"]', '+1-555-9999');
    await page.click('text=Create Store');

    // Verify store created
    await expect(page.locator('text=E2E Test Store')).toBeVisible();
    await expect(page.locator('text=Store created successfully')).toBeVisible();

    // Navigate to store details
    await page.click('text=E2E Test Store');
    await expect(page.locator('h1:has-text("E2E Test Store")')).toBeVisible();

    // Add location
    await page.click('text=Add Location');
    await page.fill('input[name="address"]', '123 Test St');
    await page.fill('input[name="city"]', 'Test City');
    await page.fill('input[name="phone"]', '+1-555-8888');
    await page.click('text=Create Location');

    // Verify location created
    await expect(page.locator('text=Test City')).toBeVisible();

    // Delete location
    await page.click('[aria-label="Delete location"]');
    await page.click('text=Delete');
    await expect(page.locator('text=Location deleted successfully')).toBeVisible();

    // Delete store
    await page.click('text=Stores List');
    await page.click('[aria-label="Delete store E2E Test Store"]');
    await page.click('text=Delete');
    await expect(page.locator('text=Store deleted successfully')).toBeVisible();
    await expect(page.locator('text=E2E Test Store')).not.toBeVisible();
  });
});
```

---

## Definition of Done

✅ All AC1-AC8 acceptance criteria met

✅ Test infrastructure configured and working

✅ Unit tests for all components passing

✅ Integration tests for all pages and forms passing

✅ E2E tests for critical user flows passing

✅ Test coverage report generated and meets thresholds (70%+)

✅ MSW handlers implemented for all API endpoints

✅ Tests run successfully in CI/CD pipeline (if AC9 implemented)

✅ Documentation added to README.md:
  - How to run tests locally
  - How to write new tests
  - Testing strategy and philosophy

✅ Code merged to main branch

---

## Estimated Effort

- **Setup & Infrastructure (AC1)**: 2-4 hours
- **Component Unit Tests (AC2)**: 4-6 hours
- **Utility Unit Tests (AC3)**: 1-2 hours
- **Page Integration Tests (AC4-AC5)**: 8-12 hours
- **E2E Tests (AC6)**: 6-8 hours
- **MSW Setup (AC7)**: 2-3 hours
- **CI/CD Integration (AC9)**: 2-3 hours
- **Documentation**: 1-2 hours

**Total**: ~26-40 hours (3-5 days)

---

## References

- [Vitest Documentation](https://vitest.dev/)
- [React Testing Library](https://testing-library.com/docs/react-testing-library/intro/)
- [Playwright Documentation](https://playwright.dev/)
- [MSW Documentation](https://mswjs.io/)
- [Testing Best Practices](https://kentcdodds.com/blog/common-mistakes-with-react-testing-library)
