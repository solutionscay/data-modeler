# Data Model Interview: Mobile Dog Grooming

## Business Overview

Mobile dog grooming operation with 3 vans and 4 groomers (owner included). Customers find the business through WhatsApp or Facebook and send a DM asking for a price. The groomer asks for a dog picture, quotes based on breed, size, and coat condition (matting), and if the customer accepts, they're given available dates and times.

Each groomer covers a geographic area and keeps their assigned van at home. There is a central storage unit where groomers go to restock supplies. If a groomer is out, the owner drives to their home and takes their van for the day.

## Services and Pricing

**Service Tiers:**
- Wash (short hair)
- Wash (long hair)
- Mini groom
- Full groom

Each tier is priced by dog size using four weight brackets:
- Up to 15 lbs
- 16-40 lbs
- 41-70 lbs
- 71+ lbs

**Add-Ons (flat rate):**
- Nails ($10)
- Teeth ($10)
- Flea/tick treatment (planned)

Appointments typically last 1-2 hours, with full grooms taking longer than washes.

## Customers and Dogs

Customers provide their name, phone number, and general area for the initial estimate. A full address is collected when they accept the quote.

A customer can have multiple dogs. All dogs are groomed in a single appointment when there are multiples. Each dog in an appointment can receive a different service tier and different add-ons.

**Dog profiles include:**
- Name, breed, size
- Photo (taken in the moment for quoting)
- Temperament
- Allergies
- Snack restrictions (some owners request no snacks or bring their own)
- Grooming preferences

Currently, dog info and grooming notes are scattered across a group chat. There is no centralized record per dog.

## Scheduling and Assignment

Scheduling and groomer/van assignment is currently managed through a group chat, which is a major pain point. A previous attempt to use Google Calendar failed because groomers didn't adopt it.

Each groomer has a geographic service area. Van assignment is semi-permanent (each groomer keeps their van at home) but can change over time.

## Appointment Lifecycle

Appointments are not currently tracked through stages, but the following statuses were identified as useful:
- Booked
- On the way
- In progress
- Completed
- Cancelled
- No-show

An appointment includes: date, time, groomer, van, customer, address, dogs, selected services, and special notes (allergies, temperament warnings, handling instructions).

## Pricing Adjustments

Sometimes on-site conditions differ from the original quote, most commonly due to excessive matting. When this happens, the groomer discusses the revised price with the owner before starting. The customer must approve the new price. This is tied to a specific dog, not the whole appointment.

## Payments

Payment is currently collected on-site, primarily via Square (card) and occasionally cash. There is no deposit or prepayment system in place.

**Desired future state:** Online prepayment, which would help reduce cancellations and no-shows. The system should support card, cash, and online payment methods.

## Cancellations and No-Shows

Cancellations and no-shows are a significant pain point. Customers sometimes cancel last minute or are not home when the groomer arrives, wasting the groomer's time. The owner wants customers to be able to cancel and reschedule online, with prepayment serving as a deterrent against no-shows.

## Post-Appointment

Currently, nothing is sent to the customer after an appointment. The owner wants to introduce before-and-after photos as a follow-up, similar to a service confirmation (like a pool cleaning service sending proof-of-work photos).

## Expenses

Groomers submit gas receipts and minor van expense photos from their phones. The owner reimburses these expenses and tracks them for bookkeeping.

**Expense details tracked:**
- Receipt photo
- Amount
- Date
- Which van the expense is for
- Expense type (gas, maintenance, etc.)
- Reimbursement status

The owner purchases all grooming supplies centrally and stores them in a storage unit. Groomers bring their own personal tools (brushes, etc.) by preference, but this is not tracked by the business.

## Entities Identified

1. **Customer** - Dog owner with contact info and address
2. **Dog** - Tied to a customer, with breed, size, photo, temperament, allergies, snack restrictions, and grooming preferences
3. **Groomer** - Team member with assigned service area
4. **Van** - Vehicle assigned to a groomer, can be reassigned
5. **Service Tier** - Grooming packages (wash short/long, mini groom, full groom)
6. **Size Bracket** - Weight-based pricing categories (4 brackets)
7. **Add-On** - Upsellable extras (nails, teeth, flea/tick)
8. **Appointment** - Scheduled groom tying together customer, groomer, van, dogs, and services
9. **Appointment Line Item** - Per-dog detail within an appointment (service tier, price, notes)
10. **Payment** - One payment per appointment, tracking method and status
11. **Price Adjustment** - On-site price change for a specific dog, with reason and customer approval
12. **Appointment Photo** - Before/after shots tied to an appointment and optionally a specific dog
13. **Expense** - Groomer-submitted costs (gas, van maintenance) with receipt photo and reimbursement tracking

## Relationships

- **Customer to Dog** - One customer can have many dogs. Every dog belongs to one customer.
- **Customer to Appointment** - One customer can have many appointments. Every appointment belongs to one customer.
- **Appointment to Dog** - Many-to-many via appointment line item. An appointment can include multiple dogs. Each dog gets its own service tier and add-ons.
- **Groomer to Van** - One-to-one current assignment, can change over time.
- **Groomer to Appointment** - One groomer handles many appointments. Every appointment has one groomer.
- **Van to Appointment** - One van per appointment.
- **Appointment to Payment** - One-to-one. One payment per appointment.
- **Appointment Line Item to Price Adjustment** - One-to-one, optional. A specific dog's line can have a price adjustment.
- **Appointment to Photos** - One appointment can have many photos.
- **Groomer to Expense** - One groomer submits many expenses.
- **Van to Expense** - Expenses are tracked per van.
- **Service Tier to Size Bracket** - Price grid. Each tier has a price for each of the 4 weight brackets.
