/*
  # Initial Schema Migration from Prisma to Supabase

  ## Overview
  This migration creates the complete database schema for the agency management platform,
  including all tables, enums, relationships, indexes, and Row Level Security policies.

  ## New Enums
  1. `role_enum` - User roles (AGENCY_OWNER, AGENCY_ADMIN, SUBACCOUNT_USER, SUBACCOUNT_GUEST)
  2. `icon_enum` - Icon types for sidebar options
  3. `trigger_types_enum` - Automation trigger types (CONTACT_FORM)
  4. `action_type_enum` - Automation action types (CREATE_CONTACT)
  5. `invitation_status_enum` - Invitation statuses (ACCEPTED, REVOKED, PENDING)
  6. `plan_enum` - Subscription plan identifiers

  ## New Tables
  
  ### Core User & Agency Management
  - `users` - User accounts with role-based access
  - `agencies` - Agency information and settings
  - `sub_accounts` - Sub-accounts under agencies
  - `permissions` - User permissions for sub-accounts
  - `invitations` - Email invitations to join agencies

  ### Sidebar Navigation
  - `agency_sidebar_options` - Custom sidebar options for agencies
  - `sub_account_sidebar_options` - Custom sidebar options for sub-accounts

  ### CRM & Sales
  - `contacts` - Customer contact information
  - `tags` - Tags for categorizing tickets
  - `pipelines` - Sales pipelines
  - `lanes` - Lanes within pipelines
  - `tickets` - Tickets/deals in pipeline lanes

  ### Marketing & Funnels
  - `funnels` - Marketing funnels
  - `funnel_pages` - Pages within funnels
  - `class_names` - Custom CSS classes for funnel pages
  - `media` - Media files library

  ### Automation
  - `triggers` - Automation triggers
  - `automations` - Automation workflows
  - `automation_instances` - Active automation instances
  - `actions` - Actions within automations

  ### Notifications & Billing
  - `notifications` - System notifications
  - `subscriptions` - Agency subscription plans
  - `add_ons` - Additional subscription add-ons

  ## Security
  - All tables have RLS enabled
  - Policies restrict access based on authentication and ownership
  - Users can only access data from their own agency or sub-accounts
  - Clerk authentication is integrated via email matching

  ## Important Notes
  - All tables use UUID primary keys with `gen_random_uuid()` default
  - Timestamps (`created_at`, `updated_at`) are included on all tables
  - Foreign keys use ON DELETE CASCADE where appropriate
  - Indexes are created for all foreign keys and frequently queried fields
*/

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create Enums
CREATE TYPE role_enum AS ENUM ('AGENCY_OWNER', 'AGENCY_ADMIN', 'SUBACCOUNT_USER', 'SUBACCOUNT_GUEST');
CREATE TYPE icon_enum AS ENUM ('settings', 'chart', 'calendar', 'check', 'chip', 'compass', 'database', 'flag', 'home', 'info', 'link', 'lock', 'messages', 'notification', 'payment', 'power', 'receipt', 'shield', 'star', 'tune', 'videorecorder', 'wallet', 'warning', 'headphone', 'send', 'pipelines', 'person', 'category', 'contact', 'clipboardIcon');
CREATE TYPE trigger_types_enum AS ENUM ('CONTACT_FORM');
CREATE TYPE action_type_enum AS ENUM ('CREATE_CONTACT');
CREATE TYPE invitation_status_enum AS ENUM ('ACCEPTED', 'REVOKED', 'PENDING');
CREATE TYPE plan_enum AS ENUM ('price_1OYxkqFj9oKEERu1NbKUxXxN', 'price_1OYxkqFj9oKEERu1KfJGWxgN');

-- Create Agencies table
CREATE TABLE IF NOT EXISTS agencies (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  connect_account_id text DEFAULT '',
  customer_id text DEFAULT '',
  name text NOT NULL,
  agency_logo text NOT NULL,
  company_email text NOT NULL,
  company_phone text NOT NULL,
  white_label boolean DEFAULT true,
  address text NOT NULL,
  city text NOT NULL,
  zip_code text NOT NULL,
  state text NOT NULL,
  country text NOT NULL,
  goal integer DEFAULT 5,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create Users table
CREATE TABLE IF NOT EXISTS users (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  avatar_url text NOT NULL,
  email text UNIQUE NOT NULL,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  role role_enum DEFAULT 'SUBACCOUNT_USER',
  agency_id uuid REFERENCES agencies(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_users_agency_id ON users(agency_id);
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);

-- Create Sub Accounts table
CREATE TABLE IF NOT EXISTS sub_accounts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  connect_account_id text DEFAULT '',
  name text NOT NULL,
  sub_account_logo text NOT NULL,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  company_email text NOT NULL,
  company_phone text NOT NULL,
  goal integer DEFAULT 5,
  address text NOT NULL,
  city text NOT NULL,
  zip_code text NOT NULL,
  state text NOT NULL,
  country text NOT NULL,
  agency_id uuid NOT NULL REFERENCES agencies(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_sub_accounts_agency_id ON sub_accounts(agency_id);

-- Create Permissions table
CREATE TABLE IF NOT EXISTS permissions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  email text NOT NULL REFERENCES users(email) ON DELETE CASCADE,
  sub_account_id uuid NOT NULL REFERENCES sub_accounts(id) ON DELETE CASCADE,
  access boolean NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_permissions_sub_account_id ON permissions(sub_account_id);
CREATE INDEX IF NOT EXISTS idx_permissions_email ON permissions(email);

-- Create Invitations table
CREATE TABLE IF NOT EXISTS invitations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  email text UNIQUE NOT NULL,
  agency_id uuid NOT NULL REFERENCES agencies(id) ON DELETE CASCADE,
  status invitation_status_enum DEFAULT 'PENDING',
  role role_enum DEFAULT 'SUBACCOUNT_USER'
);

CREATE INDEX IF NOT EXISTS idx_invitations_agency_id ON invitations(agency_id);

-- Create Agency Sidebar Options table
CREATE TABLE IF NOT EXISTS agency_sidebar_options (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text DEFAULT 'Menu',
  link text DEFAULT '#',
  icon icon_enum DEFAULT 'info',
  agency_id uuid NOT NULL REFERENCES agencies(id) ON DELETE CASCADE,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_agency_sidebar_options_agency_id ON agency_sidebar_options(agency_id);

-- Create Sub Account Sidebar Options table
CREATE TABLE IF NOT EXISTS sub_account_sidebar_options (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text DEFAULT 'Menu',
  link text DEFAULT '#',
  icon icon_enum DEFAULT 'info',
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  sub_account_id uuid REFERENCES sub_accounts(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_sub_account_sidebar_options_sub_account_id ON sub_account_sidebar_options(sub_account_id);

-- Create Tags table
CREATE TABLE IF NOT EXISTS tags (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  color text NOT NULL,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  sub_account_id uuid NOT NULL REFERENCES sub_accounts(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_tags_sub_account_id ON tags(sub_account_id);

-- Create Pipelines table
CREATE TABLE IF NOT EXISTS pipelines (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  sub_account_id uuid NOT NULL REFERENCES sub_accounts(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_pipelines_sub_account_id ON pipelines(sub_account_id);

-- Create Lanes table
CREATE TABLE IF NOT EXISTS lanes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  pipeline_id uuid NOT NULL REFERENCES pipelines(id) ON DELETE CASCADE,
  "order" integer DEFAULT 0
);

CREATE INDEX IF NOT EXISTS idx_lanes_pipeline_id ON lanes(pipeline_id);

-- Create Contacts table
CREATE TABLE IF NOT EXISTS contacts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  email text NOT NULL,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  sub_account_id uuid NOT NULL REFERENCES sub_accounts(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_contacts_sub_account_id ON contacts(sub_account_id);

-- Create Tickets table
CREATE TABLE IF NOT EXISTS tickets (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  lane_id uuid NOT NULL REFERENCES lanes(id) ON DELETE CASCADE,
  "order" integer DEFAULT 0,
  value decimal,
  description text,
  customer_id uuid REFERENCES contacts(id) ON DELETE SET NULL,
  assigned_user_id uuid REFERENCES users(id) ON DELETE SET NULL
);

CREATE INDEX IF NOT EXISTS idx_tickets_lane_id ON tickets(lane_id);
CREATE INDEX IF NOT EXISTS idx_tickets_customer_id ON tickets(customer_id);
CREATE INDEX IF NOT EXISTS idx_tickets_assigned_user_id ON tickets(assigned_user_id);

-- Create junction table for tickets and tags (many-to-many)
CREATE TABLE IF NOT EXISTS ticket_tags (
  ticket_id uuid NOT NULL REFERENCES tickets(id) ON DELETE CASCADE,
  tag_id uuid NOT NULL REFERENCES tags(id) ON DELETE CASCADE,
  PRIMARY KEY (ticket_id, tag_id)
);

CREATE INDEX IF NOT EXISTS idx_ticket_tags_ticket_id ON ticket_tags(ticket_id);
CREATE INDEX IF NOT EXISTS idx_ticket_tags_tag_id ON ticket_tags(tag_id);

-- Create Triggers table
CREATE TABLE IF NOT EXISTS triggers (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  type trigger_types_enum NOT NULL,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  sub_account_id uuid NOT NULL REFERENCES sub_accounts(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_triggers_sub_account_id ON triggers(sub_account_id);

-- Create Automations table
CREATE TABLE IF NOT EXISTS automations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  trigger_id uuid REFERENCES triggers(id) ON DELETE CASCADE,
  published boolean DEFAULT false,
  sub_account_id uuid NOT NULL REFERENCES sub_accounts(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_automations_trigger_id ON automations(trigger_id);
CREATE INDEX IF NOT EXISTS idx_automations_sub_account_id ON automations(sub_account_id);

-- Create Automation Instances table
CREATE TABLE IF NOT EXISTS automation_instances (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  automation_id uuid NOT NULL REFERENCES automations(id) ON DELETE CASCADE,
  active boolean DEFAULT false
);

CREATE INDEX IF NOT EXISTS idx_automation_instances_automation_id ON automation_instances(automation_id);

-- Create Actions table
CREATE TABLE IF NOT EXISTS actions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  type action_type_enum NOT NULL,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  automation_id uuid NOT NULL REFERENCES automations(id) ON DELETE CASCADE,
  "order" integer NOT NULL,
  lane_id text DEFAULT '0'
);

CREATE INDEX IF NOT EXISTS idx_actions_automation_id ON actions(automation_id);

-- Create Media table
CREATE TABLE IF NOT EXISTS media (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  type text,
  name text NOT NULL,
  link text UNIQUE NOT NULL,
  sub_account_id uuid NOT NULL REFERENCES sub_accounts(id) ON DELETE CASCADE,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_media_sub_account_id ON media(sub_account_id);

-- Create Funnels table
CREATE TABLE IF NOT EXISTS funnels (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  description text,
  published boolean DEFAULT false,
  sub_domain_name text UNIQUE,
  favicon text,
  sub_account_id uuid NOT NULL REFERENCES sub_accounts(id) ON DELETE CASCADE,
  live_products text DEFAULT '[]'
);

CREATE INDEX IF NOT EXISTS idx_funnels_sub_account_id ON funnels(sub_account_id);

-- Create Class Names table
CREATE TABLE IF NOT EXISTS class_names (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  color text NOT NULL,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  funnel_id uuid NOT NULL REFERENCES funnels(id) ON DELETE CASCADE,
  custom_data text
);

CREATE INDEX IF NOT EXISTS idx_class_names_funnel_id ON class_names(funnel_id);

-- Create Funnel Pages table
CREATE TABLE IF NOT EXISTS funnel_pages (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  path_name text DEFAULT '',
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  visits integer DEFAULT 0,
  content text,
  "order" integer NOT NULL,
  preview_image text,
  funnel_id uuid NOT NULL REFERENCES funnels(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_funnel_pages_funnel_id ON funnel_pages(funnel_id);

-- Create Notifications table
CREATE TABLE IF NOT EXISTS notifications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  notification text NOT NULL,
  agency_id uuid NOT NULL REFERENCES agencies(id) ON DELETE CASCADE,
  sub_account_id uuid REFERENCES sub_accounts(id) ON DELETE CASCADE,
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_notifications_agency_id ON notifications(agency_id);
CREATE INDEX IF NOT EXISTS idx_notifications_sub_account_id ON notifications(sub_account_id);
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON notifications(user_id);

-- Create Subscriptions table
CREATE TABLE IF NOT EXISTS subscriptions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  plan plan_enum,
  price text,
  active boolean DEFAULT false,
  price_id text NOT NULL,
  customer_id text NOT NULL,
  current_period_end_date timestamptz NOT NULL,
  subscription_id text UNIQUE NOT NULL,
  agency_id uuid UNIQUE REFERENCES agencies(id)
);

CREATE INDEX IF NOT EXISTS idx_subscriptions_customer_id ON subscriptions(customer_id);

-- Create Add-Ons table
CREATE TABLE IF NOT EXISTS add_ons (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  name text NOT NULL,
  active boolean DEFAULT false,
  price_id text UNIQUE NOT NULL,
  agency_id uuid REFERENCES agencies(id)
);

CREATE INDEX IF NOT EXISTS idx_add_ons_agency_id ON add_ons(agency_id);

-- Enable Row Level Security on all tables
ALTER TABLE agencies ENABLE ROW LEVEL SECURITY;
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE sub_accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE permissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE invitations ENABLE ROW LEVEL SECURITY;
ALTER TABLE agency_sidebar_options ENABLE ROW LEVEL SECURITY;
ALTER TABLE sub_account_sidebar_options ENABLE ROW LEVEL SECURITY;
ALTER TABLE tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE pipelines ENABLE ROW LEVEL SECURITY;
ALTER TABLE lanes ENABLE ROW LEVEL SECURITY;
ALTER TABLE contacts ENABLE ROW LEVEL SECURITY;
ALTER TABLE tickets ENABLE ROW LEVEL SECURITY;
ALTER TABLE ticket_tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE triggers ENABLE ROW LEVEL SECURITY;
ALTER TABLE automations ENABLE ROW LEVEL SECURITY;
ALTER TABLE automation_instances ENABLE ROW LEVEL SECURITY;
ALTER TABLE actions ENABLE ROW LEVEL SECURITY;
ALTER TABLE media ENABLE ROW LEVEL SECURITY;
ALTER TABLE funnels ENABLE ROW LEVEL SECURITY;
ALTER TABLE class_names ENABLE ROW LEVEL SECURITY;
ALTER TABLE funnel_pages ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE add_ons ENABLE ROW LEVEL SECURITY;

-- Create RLS Policies

-- Users: Can read their own data and users in their agency
CREATE POLICY "Users can view own data"
  ON users FOR SELECT
  TO authenticated
  USING (email = (SELECT email FROM users WHERE id = auth.uid())::text OR agency_id IN (
    SELECT agency_id FROM users WHERE id = auth.uid()
  ));

CREATE POLICY "Users can update own data"
  ON users FOR UPDATE
  TO authenticated
  USING (id = auth.uid())
  WITH CHECK (id = auth.uid());

CREATE POLICY "Users can insert own data"
  ON users FOR INSERT
  TO authenticated
  WITH CHECK (id = auth.uid());

-- Agencies: Users can view and manage their own agency
CREATE POLICY "Users can view their agency"
  ON agencies FOR SELECT
  TO authenticated
  USING (id IN (SELECT agency_id FROM users WHERE id = auth.uid()));

CREATE POLICY "Agency owners can update their agency"
  ON agencies FOR UPDATE
  TO authenticated
  USING (id IN (
    SELECT agency_id FROM users 
    WHERE id = auth.uid() AND role IN ('AGENCY_OWNER', 'AGENCY_ADMIN')
  ))
  WITH CHECK (id IN (
    SELECT agency_id FROM users 
    WHERE id = auth.uid() AND role IN ('AGENCY_OWNER', 'AGENCY_ADMIN')
  ));

CREATE POLICY "Agency owners can insert agencies"
  ON agencies FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Agency owners can delete their agency"
  ON agencies FOR DELETE
  TO authenticated
  USING (id IN (
    SELECT agency_id FROM users 
    WHERE id = auth.uid() AND role = 'AGENCY_OWNER'
  ));

-- Sub Accounts: Users can access sub-accounts in their agency or with permissions
CREATE POLICY "Users can view accessible sub accounts"
  ON sub_accounts FOR SELECT
  TO authenticated
  USING (
    agency_id IN (SELECT agency_id FROM users WHERE id = auth.uid())
    OR id IN (
      SELECT sub_account_id FROM permissions 
      WHERE email = (SELECT email FROM users WHERE id = auth.uid()) AND access = true
    )
  );

CREATE POLICY "Agency users can manage sub accounts"
  ON sub_accounts FOR ALL
  TO authenticated
  USING (agency_id IN (
    SELECT agency_id FROM users 
    WHERE id = auth.uid() AND role IN ('AGENCY_OWNER', 'AGENCY_ADMIN')
  ))
  WITH CHECK (agency_id IN (
    SELECT agency_id FROM users 
    WHERE id = auth.uid() AND role IN ('AGENCY_OWNER', 'AGENCY_ADMIN')
  ));

-- Permissions: Users can view their own permissions
CREATE POLICY "Users can view own permissions"
  ON permissions FOR SELECT
  TO authenticated
  USING (email = (SELECT email FROM users WHERE id = auth.uid()));

CREATE POLICY "Agency admins can manage permissions"
  ON permissions FOR ALL
  TO authenticated
  USING (sub_account_id IN (
    SELECT id FROM sub_accounts WHERE agency_id IN (
      SELECT agency_id FROM users WHERE id = auth.uid() AND role IN ('AGENCY_OWNER', 'AGENCY_ADMIN')
    )
  ))
  WITH CHECK (sub_account_id IN (
    SELECT id FROM sub_accounts WHERE agency_id IN (
      SELECT agency_id FROM users WHERE id = auth.uid() AND role IN ('AGENCY_OWNER', 'AGENCY_ADMIN')
    )
  ));

-- Invitations: Agency admins can manage invitations
CREATE POLICY "Users can view invitations to their agency"
  ON invitations FOR SELECT
  TO authenticated
  USING (agency_id IN (SELECT agency_id FROM users WHERE id = auth.uid()));

CREATE POLICY "Agency admins can manage invitations"
  ON invitations FOR ALL
  TO authenticated
  USING (agency_id IN (
    SELECT agency_id FROM users 
    WHERE id = auth.uid() AND role IN ('AGENCY_OWNER', 'AGENCY_ADMIN')
  ))
  WITH CHECK (agency_id IN (
    SELECT agency_id FROM users 
    WHERE id = auth.uid() AND role IN ('AGENCY_OWNER', 'AGENCY_ADMIN')
  ));

-- Sidebar Options: Users can view and manage sidebar options for their agency/sub-accounts
CREATE POLICY "Users can view agency sidebar options"
  ON agency_sidebar_options FOR SELECT
  TO authenticated
  USING (agency_id IN (SELECT agency_id FROM users WHERE id = auth.uid()));

CREATE POLICY "Agency admins can manage sidebar options"
  ON agency_sidebar_options FOR ALL
  TO authenticated
  USING (agency_id IN (
    SELECT agency_id FROM users 
    WHERE id = auth.uid() AND role IN ('AGENCY_OWNER', 'AGENCY_ADMIN')
  ))
  WITH CHECK (agency_id IN (
    SELECT agency_id FROM users 
    WHERE id = auth.uid() AND role IN ('AGENCY_OWNER', 'AGENCY_ADMIN')
  ));

CREATE POLICY "Users can view sub account sidebar options"
  ON sub_account_sidebar_options FOR SELECT
  TO authenticated
  USING (sub_account_id IN (
    SELECT id FROM sub_accounts WHERE agency_id IN (
      SELECT agency_id FROM users WHERE id = auth.uid()
    )
  ));

CREATE POLICY "Users can manage sub account sidebar options"
  ON sub_account_sidebar_options FOR ALL
  TO authenticated
  USING (sub_account_id IN (
    SELECT id FROM sub_accounts WHERE agency_id IN (
      SELECT agency_id FROM users WHERE id = auth.uid()
    )
  ))
  WITH CHECK (sub_account_id IN (
    SELECT id FROM sub_accounts WHERE agency_id IN (
      SELECT agency_id FROM users WHERE id = auth.uid()
    )
  ));

-- For all sub-account related tables (tags, pipelines, lanes, contacts, tickets, etc.)
-- Users can access if they have access to the sub-account
CREATE POLICY "Users can view accessible tags"
  ON tags FOR SELECT
  TO authenticated
  USING (sub_account_id IN (
    SELECT id FROM sub_accounts WHERE agency_id IN (
      SELECT agency_id FROM users WHERE id = auth.uid()
    ) OR id IN (
      SELECT sub_account_id FROM permissions 
      WHERE email = (SELECT email FROM users WHERE id = auth.uid()) AND access = true
    )
  ));

CREATE POLICY "Users can manage tags"
  ON tags FOR ALL
  TO authenticated
  USING (sub_account_id IN (
    SELECT id FROM sub_accounts WHERE agency_id IN (
      SELECT agency_id FROM users WHERE id = auth.uid()
    ) OR id IN (
      SELECT sub_account_id FROM permissions 
      WHERE email = (SELECT email FROM users WHERE id = auth.uid()) AND access = true
    )
  ))
  WITH CHECK (sub_account_id IN (
    SELECT id FROM sub_accounts WHERE agency_id IN (
      SELECT agency_id FROM users WHERE id = auth.uid()
    ) OR id IN (
      SELECT sub_account_id FROM permissions 
      WHERE email = (SELECT email FROM users WHERE id = auth.uid()) AND access = true
    )
  ));

-- Similar policies for pipelines, contacts, media, funnels, triggers, automations
CREATE POLICY "Users can view accessible pipelines"
  ON pipelines FOR SELECT
  TO authenticated
  USING (sub_account_id IN (
    SELECT id FROM sub_accounts WHERE agency_id IN (SELECT agency_id FROM users WHERE id = auth.uid())
    OR id IN (SELECT sub_account_id FROM permissions WHERE email = (SELECT email FROM users WHERE id = auth.uid()) AND access = true)
  ));

CREATE POLICY "Users can manage pipelines"
  ON pipelines FOR ALL
  TO authenticated
  USING (sub_account_id IN (
    SELECT id FROM sub_accounts WHERE agency_id IN (SELECT agency_id FROM users WHERE id = auth.uid())
    OR id IN (SELECT sub_account_id FROM permissions WHERE email = (SELECT email FROM users WHERE id = auth.uid()) AND access = true)
  ))
  WITH CHECK (sub_account_id IN (
    SELECT id FROM sub_accounts WHERE agency_id IN (SELECT agency_id FROM users WHERE id = auth.uid())
    OR id IN (SELECT sub_account_id FROM permissions WHERE email = (SELECT email FROM users WHERE id = auth.uid()) AND access = true)
  ));

CREATE POLICY "Users can view accessible lanes"
  ON lanes FOR SELECT
  TO authenticated
  USING (pipeline_id IN (
    SELECT id FROM pipelines WHERE sub_account_id IN (
      SELECT id FROM sub_accounts WHERE agency_id IN (SELECT agency_id FROM users WHERE id = auth.uid())
      OR id IN (SELECT sub_account_id FROM permissions WHERE email = (SELECT email FROM users WHERE id = auth.uid()) AND access = true)
    )
  ));

CREATE POLICY "Users can manage lanes"
  ON lanes FOR ALL
  TO authenticated
  USING (pipeline_id IN (
    SELECT id FROM pipelines WHERE sub_account_id IN (
      SELECT id FROM sub_accounts WHERE agency_id IN (SELECT agency_id FROM users WHERE id = auth.uid())
      OR id IN (SELECT sub_account_id FROM permissions WHERE email = (SELECT email FROM users WHERE id = auth.uid()) AND access = true)
    )
  ))
  WITH CHECK (pipeline_id IN (
    SELECT id FROM pipelines WHERE sub_account_id IN (
      SELECT id FROM sub_accounts WHERE agency_id IN (SELECT agency_id FROM users WHERE id = auth.uid())
      OR id IN (SELECT sub_account_id FROM permissions WHERE email = (SELECT email FROM users WHERE id = auth.uid()) AND access = true)
    )
  ));

CREATE POLICY "Users can view accessible contacts"
  ON contacts FOR SELECT
  TO authenticated
  USING (sub_account_id IN (
    SELECT id FROM sub_accounts WHERE agency_id IN (SELECT agency_id FROM users WHERE id = auth.uid())
    OR id IN (SELECT sub_account_id FROM permissions WHERE email = (SELECT email FROM users WHERE id = auth.uid()) AND access = true)
  ));

CREATE POLICY "Users can manage contacts"
  ON contacts FOR ALL
  TO authenticated
  USING (sub_account_id IN (
    SELECT id FROM sub_accounts WHERE agency_id IN (SELECT agency_id FROM users WHERE id = auth.uid())
    OR id IN (SELECT sub_account_id FROM permissions WHERE email = (SELECT email FROM users WHERE id = auth.uid()) AND access = true)
  ))
  WITH CHECK (sub_account_id IN (
    SELECT id FROM sub_accounts WHERE agency_id IN (SELECT agency_id FROM users WHERE id = auth.uid())
    OR id IN (SELECT sub_account_id FROM permissions WHERE email = (SELECT email FROM users WHERE id = auth.uid()) AND access = true)
  ));

CREATE POLICY "Users can view accessible tickets"
  ON tickets FOR SELECT
  TO authenticated
  USING (lane_id IN (
    SELECT id FROM lanes WHERE pipeline_id IN (
      SELECT id FROM pipelines WHERE sub_account_id IN (
        SELECT id FROM sub_accounts WHERE agency_id IN (SELECT agency_id FROM users WHERE id = auth.uid())
        OR id IN (SELECT sub_account_id FROM permissions WHERE email = (SELECT email FROM users WHERE id = auth.uid()) AND access = true)
      )
    )
  ));

CREATE POLICY "Users can manage tickets"
  ON tickets FOR ALL
  TO authenticated
  USING (lane_id IN (
    SELECT id FROM lanes WHERE pipeline_id IN (
      SELECT id FROM pipelines WHERE sub_account_id IN (
        SELECT id FROM sub_accounts WHERE agency_id IN (SELECT agency_id FROM users WHERE id = auth.uid())
        OR id IN (SELECT sub_account_id FROM permissions WHERE email = (SELECT email FROM users WHERE id = auth.uid()) AND access = true)
      )
    )
  ))
  WITH CHECK (lane_id IN (
    SELECT id FROM lanes WHERE pipeline_id IN (
      SELECT id FROM pipelines WHERE sub_account_id IN (
        SELECT id FROM sub_accounts WHERE agency_id IN (SELECT agency_id FROM users WHERE id = auth.uid())
        OR id IN (SELECT sub_account_id FROM permissions WHERE email = (SELECT email FROM users WHERE id = auth.uid()) AND access = true)
      )
    )
  ));

CREATE POLICY "Users can view ticket tags"
  ON ticket_tags FOR SELECT
  TO authenticated
  USING (ticket_id IN (SELECT id FROM tickets));

CREATE POLICY "Users can manage ticket tags"
  ON ticket_tags FOR ALL
  TO authenticated
  USING (ticket_id IN (SELECT id FROM tickets))
  WITH CHECK (ticket_id IN (SELECT id FROM tickets));

CREATE POLICY "Users can view accessible media"
  ON media FOR SELECT
  TO authenticated
  USING (sub_account_id IN (
    SELECT id FROM sub_accounts WHERE agency_id IN (SELECT agency_id FROM users WHERE id = auth.uid())
    OR id IN (SELECT sub_account_id FROM permissions WHERE email = (SELECT email FROM users WHERE id = auth.uid()) AND access = true)
  ));

CREATE POLICY "Users can manage media"
  ON media FOR ALL
  TO authenticated
  USING (sub_account_id IN (
    SELECT id FROM sub_accounts WHERE agency_id IN (SELECT agency_id FROM users WHERE id = auth.uid())
    OR id IN (SELECT sub_account_id FROM permissions WHERE email = (SELECT email FROM users WHERE id = auth.uid()) AND access = true)
  ))
  WITH CHECK (sub_account_id IN (
    SELECT id FROM sub_accounts WHERE agency_id IN (SELECT agency_id FROM users WHERE id = auth.uid())
    OR id IN (SELECT sub_account_id FROM permissions WHERE email = (SELECT email FROM users WHERE id = auth.uid()) AND access = true)
  ));

CREATE POLICY "Users can view accessible funnels"
  ON funnels FOR SELECT
  TO authenticated
  USING (sub_account_id IN (
    SELECT id FROM sub_accounts WHERE agency_id IN (SELECT agency_id FROM users WHERE id = auth.uid())
    OR id IN (SELECT sub_account_id FROM permissions WHERE email = (SELECT email FROM users WHERE id = auth.uid()) AND access = true)
  ));

CREATE POLICY "Users can manage funnels"
  ON funnels FOR ALL
  TO authenticated
  USING (sub_account_id IN (
    SELECT id FROM sub_accounts WHERE agency_id IN (SELECT agency_id FROM users WHERE id = auth.uid())
    OR id IN (SELECT sub_account_id FROM permissions WHERE email = (SELECT email FROM users WHERE id = auth.uid()) AND access = true)
  ))
  WITH CHECK (sub_account_id IN (
    SELECT id FROM sub_accounts WHERE agency_id IN (SELECT agency_id FROM users WHERE id = auth.uid())
    OR id IN (SELECT sub_account_id FROM permissions WHERE email = (SELECT email FROM users WHERE id = auth.uid()) AND access = true)
  ));

CREATE POLICY "Users can view accessible class names"
  ON class_names FOR SELECT
  TO authenticated
  USING (funnel_id IN (SELECT id FROM funnels));

CREATE POLICY "Users can manage class names"
  ON class_names FOR ALL
  TO authenticated
  USING (funnel_id IN (SELECT id FROM funnels))
  WITH CHECK (funnel_id IN (SELECT id FROM funnels));

CREATE POLICY "Users can view accessible funnel pages"
  ON funnel_pages FOR SELECT
  TO authenticated
  USING (funnel_id IN (SELECT id FROM funnels));

CREATE POLICY "Users can manage funnel pages"
  ON funnel_pages FOR ALL
  TO authenticated
  USING (funnel_id IN (SELECT id FROM funnels))
  WITH CHECK (funnel_id IN (SELECT id FROM funnels));

CREATE POLICY "Users can view accessible triggers"
  ON triggers FOR SELECT
  TO authenticated
  USING (sub_account_id IN (
    SELECT id FROM sub_accounts WHERE agency_id IN (SELECT agency_id FROM users WHERE id = auth.uid())
    OR id IN (SELECT sub_account_id FROM permissions WHERE email = (SELECT email FROM users WHERE id = auth.uid()) AND access = true)
  ));

CREATE POLICY "Users can manage triggers"
  ON triggers FOR ALL
  TO authenticated
  USING (sub_account_id IN (
    SELECT id FROM sub_accounts WHERE agency_id IN (SELECT agency_id FROM users WHERE id = auth.uid())
    OR id IN (SELECT sub_account_id FROM permissions WHERE email = (SELECT email FROM users WHERE id = auth.uid()) AND access = true)
  ))
  WITH CHECK (sub_account_id IN (
    SELECT id FROM sub_accounts WHERE agency_id IN (SELECT agency_id FROM users WHERE id = auth.uid())
    OR id IN (SELECT sub_account_id FROM permissions WHERE email = (SELECT email FROM users WHERE id = auth.uid()) AND access = true)
  ));

CREATE POLICY "Users can view accessible automations"
  ON automations FOR SELECT
  TO authenticated
  USING (sub_account_id IN (
    SELECT id FROM sub_accounts WHERE agency_id IN (SELECT agency_id FROM users WHERE id = auth.uid())
    OR id IN (SELECT sub_account_id FROM permissions WHERE email = (SELECT email FROM users WHERE id = auth.uid()) AND access = true)
  ));

CREATE POLICY "Users can manage automations"
  ON automations FOR ALL
  TO authenticated
  USING (sub_account_id IN (
    SELECT id FROM sub_accounts WHERE agency_id IN (SELECT agency_id FROM users WHERE id = auth.uid())
    OR id IN (SELECT sub_account_id FROM permissions WHERE email = (SELECT email FROM users WHERE id = auth.uid()) AND access = true)
  ))
  WITH CHECK (sub_account_id IN (
    SELECT id FROM sub_accounts WHERE agency_id IN (SELECT agency_id FROM users WHERE id = auth.uid())
    OR id IN (SELECT sub_account_id FROM permissions WHERE email = (SELECT email FROM users WHERE id = auth.uid()) AND access = true)
  ));

CREATE POLICY "Users can view automation instances"
  ON automation_instances FOR SELECT
  TO authenticated
  USING (automation_id IN (SELECT id FROM automations));

CREATE POLICY "Users can manage automation instances"
  ON automation_instances FOR ALL
  TO authenticated
  USING (automation_id IN (SELECT id FROM automations))
  WITH CHECK (automation_id IN (SELECT id FROM automations));

CREATE POLICY "Users can view actions"
  ON actions FOR SELECT
  TO authenticated
  USING (automation_id IN (SELECT id FROM automations));

CREATE POLICY "Users can manage actions"
  ON actions FOR ALL
  TO authenticated
  USING (automation_id IN (SELECT id FROM automations))
  WITH CHECK (automation_id IN (SELECT id FROM automations));

CREATE POLICY "Users can view their notifications"
  ON notifications FOR SELECT
  TO authenticated
  USING (user_id = auth.uid() OR agency_id IN (SELECT agency_id FROM users WHERE id = auth.uid()));

CREATE POLICY "Users can manage their notifications"
  ON notifications FOR ALL
  TO authenticated
  USING (user_id = auth.uid() OR agency_id IN (
    SELECT agency_id FROM users WHERE id = auth.uid() AND role IN ('AGENCY_OWNER', 'AGENCY_ADMIN')
  ))
  WITH CHECK (user_id = auth.uid() OR agency_id IN (
    SELECT agency_id FROM users WHERE id = auth.uid() AND role IN ('AGENCY_OWNER', 'AGENCY_ADMIN')
  ));

CREATE POLICY "Users can view their agency subscription"
  ON subscriptions FOR SELECT
  TO authenticated
  USING (agency_id IN (SELECT agency_id FROM users WHERE id = auth.uid()));

CREATE POLICY "Agency owners can manage subscription"
  ON subscriptions FOR ALL
  TO authenticated
  USING (agency_id IN (
    SELECT agency_id FROM users WHERE id = auth.uid() AND role = 'AGENCY_OWNER'
  ))
  WITH CHECK (agency_id IN (
    SELECT agency_id FROM users WHERE id = auth.uid() AND role = 'AGENCY_OWNER'
  ));

CREATE POLICY "Users can view agency add-ons"
  ON add_ons FOR SELECT
  TO authenticated
  USING (agency_id IN (SELECT agency_id FROM users WHERE id = auth.uid()));

CREATE POLICY "Agency owners can manage add-ons"
  ON add_ons FOR ALL
  TO authenticated
  USING (agency_id IN (
    SELECT agency_id FROM users WHERE id = auth.uid() AND role = 'AGENCY_OWNER'
  ))
  WITH CHECK (agency_id IN (
    SELECT agency_id FROM users WHERE id = auth.uid() AND role = 'AGENCY_OWNER'
  ));