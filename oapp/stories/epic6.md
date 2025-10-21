Epic 6: Menu Service - Menu Submission & Approval
US-6.1: Submit Menu for Review
As an owner
I want to submit my menu for DeliveryX review
So that it can be approved and go live
Acceptance Criteria:

Owner can POST to /api/v1/menus/{menu_id}/submit
System validates menu has at least 1 collection with at least 1 product
System changes menu status from "draft" to "pending_review"
System sets submitted_at timestamp
System publishes event to message queue for Approval Service
System returns 200 OK with updated status
System returns 400 if validation fails

Technical Notes:

Endpoint: POST /api/v1/menus/{menu_id}/submit
Validate menu completeness
Publish event to RabbitMQ/SQS


US-6.2: Check Menu Status
As an owner
I want to check my menu's approval status
So that I know if it's been reviewed
Acceptance Criteria:

Owner can GET /api/v1/menus/{menu_id}/status
System returns: status, submitted_at, reviewed_at, rejection_reason (if applicable)
System returns 200 OK
System returns 404 if menu doesn't exist

Technical Notes:

Endpoint: GET /api/v1/menus/{menu_id}/status


US-6.3: Approve Menu (Admin)
As an admin
I want to approve a submitted menu
So that it becomes active on the platform
Acceptance Criteria:

Admin can POST to /api/v1/approvals/menus/{menu_id}/approve
System changes menu status from "pending_review" to "approved"
System automatically changes status to "active"
System sets reviewed_at timestamp
System returns 200 OK
System returns 400 if menu is not in "pending_review"

Technical Notes:

Endpoint: POST /api/v1/approvals/menus/{menu_id}/approve
Service: Approval Service
Auto-activate after approval


US-6.4: Reject Menu (Admin)
As an admin
I want to reject a submitted menu with a reason
So that the owner can make corrections
Acceptance Criteria:

Admin can POST to /api/v1/approvals/menus/{menu_id}/reject
System accepts: {rejection_reason: string}
System changes menu status from "pending_review" to "rejected"
System sets reviewed_at timestamp and rejection_reason
System returns 200 OK
System returns 400 if menu is not in "pending_review"

Technical Notes:

Endpoint: POST /api/v1/approvals/menus/{menu_id}/reject
Service: Approval Service
