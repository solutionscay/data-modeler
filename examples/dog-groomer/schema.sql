-- Mobile Dog Grooming Schema
-- SQLite

-- ============================================================
-- Lookup / Reference Tables
-- ============================================================

CREATE TABLE size_bracket (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    label TEXT NOT NULL,
    min_weight_lbs INTEGER,
    max_weight_lbs INTEGER,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

INSERT INTO size_bracket (label, min_weight_lbs, max_weight_lbs) VALUES
    ('Small', 0, 15),
    ('Medium', 16, 40),
    ('Large', 41, 70),
    ('Extra Large', 71, NULL);

CREATE TABLE service_tier (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    description TEXT,
    estimated_duration_minutes INTEGER,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE service_tier_price (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    service_tier_id INTEGER NOT NULL REFERENCES service_tier(id),
    size_bracket_id INTEGER NOT NULL REFERENCES size_bracket(id),
    price_cents INTEGER NOT NULL,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    updated_at TEXT NOT NULL DEFAULT (datetime('now')),
    UNIQUE (service_tier_id, size_bracket_id)
);

CREATE INDEX idx_service_tier_price_tier ON service_tier_price(service_tier_id);
CREATE INDEX idx_service_tier_price_size ON service_tier_price(size_bracket_id);

CREATE TABLE add_on (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    price_cents INTEGER NOT NULL,
    active INTEGER NOT NULL DEFAULT 1,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

-- ============================================================
-- People & Animals
-- ============================================================

CREATE TABLE customer (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    phone TEXT NOT NULL,
    area TEXT,
    address TEXT,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX idx_customer_phone ON customer(phone);

CREATE TABLE dog (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    customer_id INTEGER NOT NULL REFERENCES customer(id),
    name TEXT NOT NULL,
    breed TEXT,
    size_bracket_id INTEGER REFERENCES size_bracket(id),
    photo_url TEXT,
    temperament TEXT,
    allergies TEXT,
    snack_restrictions TEXT,
    grooming_preferences TEXT,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX idx_dog_customer ON dog(customer_id);

CREATE TABLE groomer (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    phone TEXT NOT NULL,
    service_area TEXT,
    active INTEGER NOT NULL DEFAULT 1,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE van (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    current_groomer_id INTEGER REFERENCES groomer(id),
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX idx_van_groomer ON van(current_groomer_id);

-- ============================================================
-- Appointments
-- ============================================================

CREATE TABLE appointment (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    customer_id INTEGER NOT NULL REFERENCES customer(id),
    groomer_id INTEGER NOT NULL REFERENCES groomer(id),
    van_id INTEGER NOT NULL REFERENCES van(id),
    address TEXT NOT NULL,
    scheduled_date TEXT NOT NULL,
    scheduled_time TEXT NOT NULL,
    estimated_duration_minutes INTEGER,
    status TEXT NOT NULL DEFAULT 'booked'
        CHECK (status IN ('booked', 'on_the_way', 'in_progress', 'completed', 'cancelled', 'no_show')),
    notes TEXT,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX idx_appointment_customer ON appointment(customer_id);
CREATE INDEX idx_appointment_groomer ON appointment(groomer_id);
CREATE INDEX idx_appointment_van ON appointment(van_id);
CREATE INDEX idx_appointment_date ON appointment(scheduled_date);
CREATE INDEX idx_appointment_status ON appointment(status);

-- Each dog in an appointment gets its own line item with service and price
CREATE TABLE appointment_line_item (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    appointment_id INTEGER NOT NULL REFERENCES appointment(id) ON DELETE CASCADE,
    dog_id INTEGER NOT NULL REFERENCES dog(id),
    service_tier_id INTEGER NOT NULL REFERENCES service_tier(id),
    quoted_price_cents INTEGER NOT NULL,
    notes TEXT,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX idx_line_item_appointment ON appointment_line_item(appointment_id);
CREATE INDEX idx_line_item_dog ON appointment_line_item(dog_id);

-- Add-ons selected for a specific dog in an appointment
CREATE TABLE line_item_add_on (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    appointment_line_item_id INTEGER NOT NULL REFERENCES appointment_line_item(id) ON DELETE CASCADE,
    add_on_id INTEGER NOT NULL REFERENCES add_on(id),
    price_cents INTEGER NOT NULL,
    created_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX idx_line_item_add_on_item ON line_item_add_on(appointment_line_item_id);

-- Price adjustment when on-site conditions differ from the quote
CREATE TABLE price_adjustment (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    appointment_line_item_id INTEGER NOT NULL REFERENCES appointment_line_item(id) ON DELETE CASCADE,
    original_price_cents INTEGER NOT NULL,
    adjusted_price_cents INTEGER NOT NULL,
    reason TEXT NOT NULL,
    customer_approved INTEGER NOT NULL DEFAULT 0,
    created_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX idx_price_adj_line_item ON price_adjustment(appointment_line_item_id);

-- ============================================================
-- Payment
-- ============================================================

CREATE TABLE payment (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    appointment_id INTEGER NOT NULL REFERENCES appointment(id),
    amount_cents INTEGER NOT NULL,
    method TEXT NOT NULL CHECK (method IN ('card', 'cash', 'online')),
    status TEXT NOT NULL DEFAULT 'pending'
        CHECK (status IN ('pending', 'completed', 'refunded')),
    paid_at TEXT,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE UNIQUE INDEX idx_payment_appointment ON payment(appointment_id);

-- ============================================================
-- Photos
-- ============================================================

CREATE TABLE appointment_photo (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    appointment_id INTEGER NOT NULL REFERENCES appointment(id) ON DELETE CASCADE,
    dog_id INTEGER REFERENCES dog(id),
    photo_url TEXT NOT NULL,
    photo_type TEXT NOT NULL CHECK (photo_type IN ('before', 'after')),
    created_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX idx_photo_appointment ON appointment_photo(appointment_id);

-- ============================================================
-- Expenses
-- ============================================================

CREATE TABLE expense (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    groomer_id INTEGER NOT NULL REFERENCES groomer(id),
    van_id INTEGER NOT NULL REFERENCES van(id),
    amount_cents INTEGER NOT NULL,
    expense_type TEXT NOT NULL CHECK (expense_type IN ('gas', 'maintenance', 'supplies', 'other')),
    description TEXT,
    receipt_photo_url TEXT,
    expense_date TEXT NOT NULL,
    reimbursed INTEGER NOT NULL DEFAULT 0,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX idx_expense_groomer ON expense(groomer_id);
CREATE INDEX idx_expense_van ON expense(van_id);
CREATE INDEX idx_expense_date ON expense(expense_date);
