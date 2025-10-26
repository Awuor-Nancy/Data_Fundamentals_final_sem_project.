# ✈️ Data_Fundamentals_final_sem_project — JetBlue Flight Booking System

<div align="center">
  <img width="88" height="40" alt="image" src="https://github.com/user-attachments/assets/5edb3297-2f15-4111-8a8b-56c199137dd7" />
</div>

---

## 📖 Table of Contents
- [📘 Project Purpose](#-project-purpose)
- [🗂️ Schema Overview](#%EF%B8%8F-schema-overview)
- [🔗 Relationships](#-relationships)
- [🧩 ERD (Entity-Relationship-Diagram)](#-erd-entity-relationship-diagram)
- [🧮 Example Queries](#-example-queries)
- [⚙️ Technologies Used](#%EF%B8%8F-technologies-used)
- [🚀 How to Use](#-how-to-use)
- [📊 Key Learnings](#-key-learnings)
- [🧠 Author](#-author)

---

## 📘 Project Purpose
This repository contains a relational database schema and sample data for a simplified **JetBlue Flight Booking System**.  

**Purpose:**
- Demonstrate relational database design and normalization.  
- Build and test SQL queries that answer practical airline questions (bookings, passenger counts, pricing).  
- Provide documentation (README, ERD, and data dictionary) suitable for submission and future extension.

---

## 🗂️ Schema Overview
The database contains **three main tables**:

| Table | Description |
|--------|--------------|
| **flights** | Flight schedules and operational details. |
| **passengers** | Passenger information, including names and loyalty status. |
| **bookings** | Junction table linking passengers to flights with ticket details. |

### 🧱 Current Table Definitions (from `schema.sql`)

```sql
-- Flights table
CREATE TABLE flights (
  flight_id SERIAL PRIMARY KEY,
  flight_number VARCHAR(10),
  origin VARCHAR(50),
  destination VARCHAR(50),
  departure_time TIMESTAMP,
  arrival_time TIMESTAMP,
  status VARCHAR(20)
);

-- Passengers table
CREATE TABLE passengers (
  passenger_id SERIAL PRIMARY KEY,
  first_name VARCHAR(50),
  last_name VARCHAR(50),
  email VARCHAR(100),
  loyalty_status VARCHAR(20)
);

-- Bookings table
CREATE TABLE bookings (
  booking_id SERIAL PRIMARY KEY,
  flight_id INT REFERENCES flights(flight_id),
  passenger_id INT REFERENCES passengers(passenger_id),
  seat_number VARCHAR(10),
  ticket_price DECIMAL(10,2),
  booking_date DATE
);

```
🔗 Relationships

bookings.flight_id → references flights.flight_id (one flight → many bookings)

bookings.passenger_id → references passengers.passenger_id (one passenger → many bookings)

Effectively: flights ↔ passengers is a many-to-many relationship implemented via the bookings table.

🧩 ERD (Entity Relationship Diagram)

The ERD visualizes the three tables and their keys/relations.

File: docs/ERD.png
Embed in README (renders on GitHub):

![ERD Diagram](docs/ERD.png)


(If the ERD image does not appear, confirm docs/ERD.png is committed to the dev_branch.)

---

🧮 Example Queries

Copy these into Supabase SQL editor to test:

-- 1) List all upcoming flights
SELECT flight_number, origin, destination, departure_time, status
FROM flights
ORDER BY departure_time;

-- 2) Bookings for passenger with last name 'Santos'
SELECT p.first_name, p.last_name, f.flight_number, f.destination, b.seat_number, b.ticket_price
FROM bookings b
JOIN passengers p ON b.passenger_id = p.passenger_id
JOIN flights f ON b.flight_id = f.flight_id
WHERE p.last_name = 'Santos';

-- 3) Count passengers per flight
SELECT f.flight_number, COUNT(b.booking_id) AS total_bookings
FROM bookings b
JOIN flights f ON f.flight_id = b.flight_id
GROUP BY f.flight_number
ORDER BY total_bookings DESC;

-- 4) Average ticket price by route
SELECT f.origin, f.destination, ROUND(AVG(b.ticket_price),2) AS avg_ticket_price
FROM bookings b
JOIN flights f ON f.flight_id = b.flight_id
GROUP BY f.origin, f.destination;

---

⚙️ Technologies Used

Supabase (PostgreSQL) — host and SQL editor used for schema and queries

SQL — schema definition, inserts, and analysis queries

GitHub — repository and documentation (this README)

---

🚀 How to Use

Ensure you are on the dev_branch in your GitHub repo (do not push to main until ready).

In Supabase:

Open the SQL editor, paste and run the schema.sql contents to create tables.

Run data.sql (or your insert statements) to populate sample data.

Run example queries from the Example Queries section to verify behavior.

Save screenshots of:

Table structure in Supabase

Query results (examples above)

ERD export
Place images in /docs/screenshots/ and reference them in this README if needed.

---

📊 Key Learnings

Designed a normalized schema to prevent data duplication.

Used foreign keys to enforce referential integrity between tables.

Practiced SQL join strategies and aggregation for business questions (passenger counts, pricing).

Prepared documentation (README, ERD, data dictionary) suitable for class submission and collaboration.

---

🧠 Author

Nancy Anyango (Project Owner)

GitHub: https://github.com/Awuor-Nancy

Email: anyangnancy@gmail.com
