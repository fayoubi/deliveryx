package repository

import (
	"database/sql"
	"fmt"

	"github.com/deliveryx/approval-service/internal/models"
	"github.com/google/uuid"
)

type ApprovalRepository struct {
	db *sql.DB
}

func NewApprovalRepository(db *sql.DB) *ApprovalRepository {
	return &ApprovalRepository{db: db}
}

// LogApproval logs an approval action
func (r *ApprovalRepository) LogApproval(menuID string, adminEmail *string) error {
	logID := uuid.New().String()

	query := `
		INSERT INTO approval_logs (id, menu_id, action, admin_email)
		VALUES ($1, $2, 'approved', $3)
	`

	_, err := r.db.Exec(query, logID, menuID, adminEmail)
	if err != nil {
		return fmt.Errorf("failed to log approval: %w", err)
	}

	return nil
}

// LogRejection logs a rejection action
func (r *ApprovalRepository) LogRejection(menuID string, rejectionReason string, adminEmail *string) error {
	logID := uuid.New().String()

	query := `
		INSERT INTO approval_logs (id, menu_id, action, admin_email, rejection_reason)
		VALUES ($1, $2, 'rejected', $3, $4)
	`

	_, err := r.db.Exec(query, logID, menuID, adminEmail, rejectionReason)
	if err != nil {
		return fmt.Errorf("failed to log rejection: %w", err)
	}

	return nil
}

// GetApprovalHistory retrieves approval history for a menu
func (r *ApprovalRepository) GetApprovalHistory(menuID string) ([]models.ApprovalLog, error) {
	query := `
		SELECT id, menu_id, action, admin_id, admin_email, rejection_reason, created_at
		FROM approval_logs
		WHERE menu_id = $1
		ORDER BY created_at DESC
	`

	rows, err := r.db.Query(query, menuID)
	if err != nil {
		return nil, fmt.Errorf("failed to get approval history: %w", err)
	}
	defer rows.Close()

	var logs []models.ApprovalLog
	for rows.Next() {
		var log models.ApprovalLog
		err := rows.Scan(
			&log.ID,
			&log.MenuID,
			&log.Action,
			&log.AdminID,
			&log.AdminEmail,
			&log.RejectionReason,
			&log.CreatedAt,
		)
		if err != nil {
			return nil, fmt.Errorf("failed to scan approval log: %w", err)
		}
		logs = append(logs, log)
	}

	return logs, nil
}
