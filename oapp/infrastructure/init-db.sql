-- Initialize DeliveryX Databases
-- This script creates the three required databases for local development

-- Create databases
CREATE DATABASE deliveryx_restaurant;
CREATE DATABASE deliveryx_menu;
CREATE DATABASE deliveryx_approval;

-- Grant all privileges to deliveryx user
GRANT ALL PRIVILEGES ON DATABASE deliveryx_restaurant TO deliveryx;
GRANT ALL PRIVILEGES ON DATABASE deliveryx_menu TO deliveryx;
GRANT ALL PRIVILEGES ON DATABASE deliveryx_approval TO deliveryx;
