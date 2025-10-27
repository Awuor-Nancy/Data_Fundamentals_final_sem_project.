# ✈️ Data_Fundamentals_final_sem_project — JetBlue Flight Booking System

<div align="center">
  <img width="88" height="40" alt="image" src="https://github.com/user-attachments/assets/5edb3297-2f15-4111-8a8b-56c199137dd7" />
</div>

---

## 📖 Table of Contents  
- [📘 Project Purpose](#-project-purpose)  
- [🗂️ Schema Overview](#%EF%B8%8F-schema-overview)  
- [🔗 Relationships](#-relationships)  
- [🧩 ERD (Entity Relationship Diagram)](#-erd-entity-relationship-diagram)  
- [🧮 Example Queries](#-example-queries)  
- [🔐 Security & RLS Setup](#-security--rls-setup)  
- [🧠 Roles and Policies](#-roles-and-policies)  
- [⚙️ Custom Admin Function](#%EF%B8%8F-custom-admin-function)  
- [🧰 Technologies Used](#%EF%B8%8F-technologies-used)  
- [🚀 How to Use](#-how-to-use)  
- [📊 Key Learnings](#-key-learnings)  
- [🧑‍💻 Author](#-author)  

---

## 📘 Project Purpose  
This repository contains a relational database schema and security setup for a **JetBlue Flight Booking System** built using **Supabase (PostgreSQL)**.

**Purpose:**  
- Demonstrate relational database design and normalization.  
- Implement Row Level Security (RLS) with Admin/User roles.  
- Build and test SQL queries for practical airline data scenarios.  
- Document setup for future academic or professional use.  

---

## 🗂️ Schema Overview  

| Table | Description |
|--------|--------------|
| **flights** | Flight schedules and operational details. |
| **passengers** | Passenger details, including name, email, and loyalty status. |
| **bookings** | Links passengers to flights with seat and ticket details. |

### 🧱 SQL Definitions
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

---

🔗 Relationships

bookings.flight_id → references flights.flight_id (One flight → Many bookings)

bookings.passenger_id → references passengers.passenger_id (One passenger → Many bookings)

➡️ Result: Many-to-Many relationship between flights and passengers through bookings.
---

🧩 ERD (Entity Relationship Diagram)

Visual representation of tables and their connections:

(Ensure the image file docs/ERD.png is committed to your repository.)

---

🧮 Example Queries

-- 1️⃣ List all upcoming flights
SELECT flight_number, origin, destination, departure_time, status
FROM flights
ORDER BY departure_time;

-- 2️⃣ Find bookings for a passenger named 'Santos'
SELECT p.first_name, p.last_name, f.flight_number, f.destination, b.seat_number, b.ticket_price
FROM bookings b
JOIN passengers p ON b.passenger_id = p.passenger_id
JOIN flights f ON b.flight_id = f.flight_id
WHERE p.last_name = 'Santos';

-- 3️⃣ Count total passengers per flight
SELECT f.flight_number, COUNT(b.booking_id) AS total_bookings
FROM bookings b
JOIN flights f ON f.flight_id = b.flight_id
GROUP BY f.flight_number
ORDER BY total_bookings DESC;

-- 4️⃣ Average ticket price by route
SELECT f.origin, f.destination, ROUND(AVG(b.ticket_price), 2) AS avg_ticket_price
FROM bookings b
JOIN flights f ON f.flight_id = b.flight_id
GROUP BY f.origin, f.destination;

---
🔐 Security & RLS Setup
✅ Enable Row-Level Security
ALTER TABLE flights ENABLE ROW LEVEL SECURITY;
ALTER TABLE passengers ENABLE ROW LEVEL SECURITY;
ALTER TABLE bookings ENABLE ROW LEVEL SECURITY;

---
✅ Create User Roles Table
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT auth.uid(),
  email TEXT UNIQUE NOT NULL,
  role TEXT CHECK (role IN ('admin', 'user')) DEFAULT 'user'
);

-- 
Insert sample users
INSERT INTO users (id, email, role)
VALUES 
  (gen_random_uuid(), 'admin@jetblue.com', 'admin'),
  (gen_random_uuid(), 'nancy@jetblue.com', 'user'),
  (gen_random_uuid(), 'barnabas@jetblue.com', 'user');

-- Enable pgcrypto (required for UUIDs)
CREATE EXTENSION IF NOT EXISTS "pgcrypto";


-- 
🧠 Roles and Policies
👩‍✈️ Admin Role

Full access — can read, insert, update, and delete any record.

👤 Regular User Role

Restricted — can only view and insert their own records.

Users can view their own passenger record
CREATE POLICY "Users can view own passenger record"
ON passengers
FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

-- Users can insert their own passenger record
CREATE POLICY "Users can insert own passenger record"
ON passengers
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

-- Admins have full access to all passenger data
CREATE POLICY "Admins manage all passenger data"
ON passengers
FOR ALL
USING (
  EXISTS (
    SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin'
  )
);

-- Admins can delete flights
CREATE POLICY "Only admins can delete flights"
ON flights
FOR DELETE
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin'
  )
);


---

⚙️ Custom Admin Function
This function allows only admins to delete flights securely.
CREATE OR REPLACE FUNCTION delete_flight(flight_to_delete INT)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Verify admin role
  IF NOT EXISTS (
    SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin'
  ) THEN
    RAISE EXCEPTION 'Access denied. Admins only.';
  END IF;

  -- Delete flight
  DELETE FROM flights WHERE flight_id = flight_to_delete;
END;
$$;

---

🧰 Technologies Used

Supabase (PostgreSQL) — Database and SQL editor

SQL — Schema creation, RLS, and functions

GitHub — Repository hosting and documentation

---

🚀 How to Use

Clone the repository and open your Supabase project.

Paste and execute all SQL scripts from this README or schema.sql.

Insert sample data for flights, passengers, and bookings.

Enable RLS and test with both Admin and User accounts.

Run example queries and test access restrictions.

Capture screenshots of:

ERD diagram

Supabase tables

Policy settings

Successful function execution

---

📊 Key Learnings

Designed a normalized relational schema to eliminate redundancy.

Implemented Row-Level Security (RLS) for secure multi-user access.

Used Supabase Auth and SQL functions for role-based control.

Practiced JOINs, aggregations, and data integrity enforcement.

Created professional GitHub documentation with clickable sections.

---

🧑‍💻 Author

Nancy Anyango — Data Analyst & Developer

GitHub: Awuor-Nancy

Email: anyangnancy@gmail.com
