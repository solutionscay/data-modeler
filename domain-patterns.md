# Common Domain Patterns

Pre-built entity/relationship patterns for common business domains. Use these to accelerate
the interview — if the user's domain matches one of these, you can start with this pattern
and customize rather than building from scratch.

These are starting points, NOT templates. Always validate with the user.

---

## E-Commerce / Retail

### Core Entities
- `customer` — name, email, phone
- `product` — name, description, sku, price, status
- `category` — name, slug, parent_category_id (self-referential tree)
- `order` — customer_id, status, total, placed_at, shipped_at
- `line_item` — order_id, product_id, quantity, unit_price, subtotal
- `address` — customer_id, type (billing/shipping), street, city, state, zip
- `payment` — order_id, method, amount, status, processed_at

### Key Relationships
- Customer → Order (one-to-many)
- Order → LineItem (one-to-many, cascade delete)
- Product → LineItem (one-to-many)
- Customer → Address (one-to-many)
- Category → Category (self-referential, tree)

### Common Questions to Ask
- Do you have product variants (size, color)? → `variant` entity
- Do prices change over time? → price history tracking
- Do you offer discounts or coupons? → `discount` / `coupon` entities
- Is inventory tracked? → `inventory` entity or stock fields on product
- Do you support guest checkout? → customer_id nullable on order

---

## SaaS / Multi-Tenant

### Core Entities
- `organization` — name, slug, plan, billing_email
- `user` — email, name, organization_id
- `role` — name, permissions (or separate `permission` entity)
- `user_role` — user_id, role_id (junction)
- `subscription` — organization_id, plan_id, status, started_at, expires_at
- `plan` — name, price, features, limits
- `invite` — organization_id, email, role_id, token, accepted_at

### Key Relationships
- Organization → User (one-to-many)
- User ↔ Role (many-to-many via user_role)
- Organization → Subscription (one-to-many, usually one active)
- Subscription → Plan (many-to-one)

### Common Questions to Ask
- Can a user belong to multiple organizations?
- What's your permission model? (RBAC, ABAC, simple roles)
- Do you need audit logging? → `audit_log` entity
- Do you offer free trials? → trial fields on subscription
- Do you have feature flags? → `feature_flag` entity

---

## Medical / Healthcare

### Core Entities
- `patient` — name, dob, gender, contact info
- `provider` — name, specialty, license_number, npi
- `appointment` — patient_id, provider_id, scheduled_at, status, type
- `encounter` — patient_id, provider_id, appointment_id, notes, diagnosis_codes
- `medication` — name, dosage_form, ndc_code
- `prescription` — patient_id, provider_id, medication_id, dosage, frequency, start/end
- `insurance` — patient_id, carrier, policy_number, group_number

### Key Relationships
- Patient → Appointment (one-to-many)
- Provider → Appointment (one-to-many)
- Appointment → Encounter (one-to-one or one-to-many)
- Patient → Prescription (one-to-many)
- Provider → Prescription (one-to-many, prescribing doctor)

### Common Questions to Ask
- HIPAA compliance needs? (affects encryption, audit logging)
- Do you track insurance claims and billing? → `claim`, `charge` entities
- Multiple providers per encounter? → junction table
- Do you need ICD/CPT code tables? → `diagnosis_code`, `procedure_code`
- Patient portal needs? → separate user/auth model

---

## Legal / Case Management

### Core Entities
- `client` — name, type (individual/business), contact info
- `matter` — client_id, title, type, status, opened_at, closed_at
- `attorney` — name, bar_number, specialty
- `matter_attorney` — matter_id, attorney_id, role (lead/associate)
- `document` — matter_id, title, type, file_path, uploaded_by, version
- `time_entry` — matter_id, attorney_id, date, hours, rate, description
- `invoice` — matter_id, client_id, amount, status, issued_at

### Key Relationships
- Client → Matter (one-to-many)
- Matter ↔ Attorney (many-to-many via matter_attorney)
- Matter → Document (one-to-many)
- Matter → TimeEntry (one-to-many)

### Common Questions to Ask
- Billing model? (hourly, flat fee, contingency, mixed)
- Trust/retainer accounting? → `trust_account`, `trust_transaction`
- Conflict checking? → `related_party` entity for conflict searches
- Court deadlines? → `deadline` / `calendar_event` entity
- Document versioning needs?

---

## Scheduling / Booking

### Core Entities
- `provider` — name, email, type (person, room, equipment)
- `service` — name, duration_minutes, price
- `availability` — provider_id, day_of_week, start_time, end_time
- `booking` — provider_id, service_id, customer_id, starts_at, ends_at, status
- `customer` — name, email, phone
- `block` — provider_id, starts_at, ends_at, reason (vacation, lunch, etc.)

### Key Relationships
- Provider → Availability (one-to-many)
- Provider → Booking (one-to-many)
- Service → Booking (many-to-one)
- Customer → Booking (one-to-many)

### Common Questions to Ask
- Can one booking require multiple providers? → junction table
- Recurring appointments? → `recurrence_rule` or separate pattern
- Buffer time between bookings?
- Cancellation/rescheduling policy? → status tracking, cancellation fields
- Time zones? → store in UTC, track customer timezone
- Group bookings? → booking capacity fields

---

## CRM / Sales Pipeline

### Core Entities
- `contact` — name, email, phone, company_id
- `company` — name, industry, size, website
- `deal` — title, company_id, contact_id, stage, value, probability, close_date
- `pipeline` — name (e.g., "Sales", "Partnerships")
- `stage` — pipeline_id, name, position, probability
- `activity` — deal_id, contact_id, type (call/email/meeting), notes, completed_at
- `note` — polymorphic (on contact, company, or deal)

### Key Relationships
- Company → Contact (one-to-many)
- Contact → Deal (one-to-many)
- Pipeline → Stage (one-to-many, ordered)
- Deal → Stage (many-to-one, current stage)
- Deal → Activity (one-to-many)

### Common Questions to Ask
- Multiple pipelines or just one?
- Deal ownership — single rep or team-based?
- Lead scoring? → scoring fields or separate `lead_score` entity
- Integration with email? → `email_message` entity
- Custom fields? → EAV pattern or JSON columns

---

## Inventory / Warehouse

### Core Entities
- `product` — sku, name, description, unit_of_measure
- `warehouse` — name, code, address
- `location` — warehouse_id, aisle, shelf, bin (hierarchical)
- `stock` — product_id, location_id, quantity, reserved_quantity
- `purchase_order` — supplier_id, status, ordered_at, received_at
- `po_line` — purchase_order_id, product_id, quantity, unit_cost
- `supplier` — name, contact info, lead_time_days

### Key Relationships
- Warehouse → Location (one-to-many, hierarchical)
- Product + Location → Stock (composite, one per combo)
- Supplier → PurchaseOrder (one-to-many)
- PurchaseOrder → POLine (one-to-many)

### Common Questions to Ask
- Lot/batch tracking? → `lot` entity
- Serial number tracking? → `serial_number` entity
- Multiple units of measure? → `unit_conversion` entity
- Stock transfers between locations? → `transfer` entity
- Minimum stock alerts? → reorder_point fields on product or stock

---

## General Tips for Any Domain

### Always Ask About
1. **Reporting** — "What reports do you run?" (reveals hidden entities and relationships)
2. **Search** — "What do you search by?" (reveals index needs)
3. **Notifications** — "Who gets notified when X happens?" (reveals event/subscription patterns)
4. **Permissions** — "Who can see/edit what?" (reveals access control needs)
5. **Integrations** — "What other systems does this talk to?" (reveals external ID fields)

### Red Flags That Suggest Missing Entities
- A field that's a comma-separated list → needs its own table
- A set of numbered columns (address1, address2, address3) → needs its own table
- A "type" or "category" field with business logic attached → probably its own entity
- A "notes" or "comments" field → might need a polymorphic notes table
- Any field with "other" as a valid value → the taxonomy needs work
