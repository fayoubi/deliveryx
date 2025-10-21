package database

import (
	"database/sql"
	"time"

	_ "github.com/lib/pq"
)

// NewPostgresConnection creates a new PostgreSQL connection pool
func NewPostgresConnection(dsn string) (*sql.DB, error) {
	db, err := sql.Open("postgres", dsn)
	if err != nil {
		return nil, err
	}

	// Set connection pool settings
	db.SetMaxOpenConns(25)
	db.SetMaxIdleConns(5)
	db.SetConnMaxLifetime(5 * time.Minute)

	// Test connection
	if err := db.Ping(); err != nil {
		return nil, err
	}

	return db, nil
}
