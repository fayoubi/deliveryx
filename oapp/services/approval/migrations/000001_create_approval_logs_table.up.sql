-- Create approval_logs table
CREATE TYPE approval_action AS ENUM ('approved', 'rejected');

CREATE TABLE IF NOT EXISTS approval_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    menu_id UUID NOT NULL,
    action approval_action NOT NULL,
    admin_id UUID,
    admin_email VARCHAR(255),
    rejection_reason TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create index on menu_id for lookups
CREATE INDEX idx_approval_logs_menu_id ON approval_logs(menu_id);

-- Create index on created_at for audit trails
CREATE INDEX idx_approval_logs_created_at ON approval_logs(created_at);
