# 🛫 JetBlue Flight Booking System

A Supabase + SQL powered airline management system that allows administrators and users to manage flights, bookings, and passengers securely using Role-Based Access Control (RLS).
---

📚 Table of Contents

1. - Overview

2. - Features

3. - Database Schema

4. - Entity-Relationship Diagram (ERD)

5. - Data Dictionary

6. - Row-Level Security (RLS) Policies

7. - User Roles & Permissions

8. - Custom SQL Functions

9. - Setup Instructions

10. - License
---

🧩 Overview

The JetBlue Flight Booking System enables secure management of:

- Flight scheduling

- Passenger records

- Booking details

It uses Supabase for authentication, storage, and PostgreSQL database management with fine-grained Row-Level Security (RLS).

✨ Features

- ✅ Role-based access: Admin and User
- ✅ Secure Row-Level Security (RLS)
- ✅ CRUD operations with restrictions
- ✅ Custom SQL functions (admin-only)
- ✅ Integrated with Supabase Auth
- ✅ Easy schema deployment via schema.sql

🧱 Database Schema

The system is structured around four core tables:

| Table          | Description                                                 |
| -------------- | ----------------------------------------------------------- |
| **flights**    | Stores flight details and status.                           |
| **passengers** | Stores passenger information linked to authenticated users. |
| **bookings**   | Connects passengers to flights with booking details.        |
| **users**      | Manages roles (`admin`, `user`) and links to Supabase Auth. |


## 🧱 SQL Definitions

```sql
-- Flights Table
CREATE TABLE flights (
  flight_id SERIAL PRIMARY KEY,
  flight_number VARCHAR(10),
  origin VARCHAR(50),
  destination VARCHAR(50),
  departure_time TIMESTAMP,
  arrival_time TIMESTAMP,
  status VARCHAR(20)
);

-- Passengers Table
CREATE TABLE passengers (
  passenger_id SERIAL PRIMARY KEY,
  first_name VARCHAR(50),
  last_name VARCHAR(50),
  email VARCHAR(100),
  loyalty_status VARCHAR(20)
);

-- Bookings Table
CREATE TABLE bookings (
  booking_id SERIAL PRIMARY KEY,
  flight_id INT REFERENCES flights(flight_id),
  passenger_id INT REFERENCES passengers(passenger_id),
  seat_number VARCHAR(10),
  ticket_price DECIMAL(10,2),
  booking_date DATE
);
```

## 🖼️ Table Screenshots
✈️ Flights Table
<p align="center"> <<img width="1358" height="673" alt="flights_table" src="https://github.com/user-attachments/assets/9a65797f-8650-4850-9572-4e9d13a08dce" />
 /> </p>

 
👥 Passengers Table
<p align="center"> <<img width="1362" height="662" alt="passengers_table" src="https://github.com/user-attachments/assets/39220f3e-f6c4-4a4c-82f3-e82df34e929f" />
" /> </p>
 
🎟️ Bookings Table
<p align="center"> <<img width="1041" height="692" alt="bookings_table" src="https://github.com/user-attachments/assets/941136ab-b214-4871-bfa9-5a73a18804f9" />
</p>

---

🔗 Relationships

bookings.flight_id → flights.flight_id → (One flight → Many bookings)

bookings.passenger_id → passengers.passenger_id → (One passenger → Many bookings)

➡️ Result: Many-to-Many relationship between flights and passengers through bookings.

🧩 ERD (Entity Relationship Diagram)
<p align="center"> <img width="1177" height="736" alt="ERD Diagram" src="https://github.com/user-attachments/assets/fc45842f-e8c3-4533-8985-2692f8c6e679" /> </p>
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
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email TEXT UNIQUE NOT NULL,
  role TEXT CHECK (role IN ('admin', 'user')) DEFAULT 'user'
);

-- Sample user data
INSERT INTO users (id, email, role)
VALUES 
  (gen_random_uuid(), 'admin@jetblue.com', 'admin'),
  (gen_random_uuid(), 'anyangnancy@gmail.com', 'user'),
  (gen_random_uuid(), 'awuornancy66@gmail.com', 'user');

-- 
🧠 Roles and Policies
👩‍✈️ Admin Role

Admins have full access — can read, insert, update, and delete any record.

👤 User Role

Regular users have restricted access — can view or insert only their own data.

```
-- Users can view their own passenger record
CREATE POLICY "Users can view own passenger record"
ON passengers
FOR SELECT
TO authenticated
USING (auth.uid() = id);

-- Users can insert their own passenger record
CREATE POLICY "Users can insert own passenger record"
ON passengers
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = id);

-- Admins manage all passenger data
CREATE POLICY "Admins manage all passenger data"
ON passengers
FOR ALL
USING (EXISTS (
  SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin'
));

-- Only admins can delete flights
CREATE POLICY "Only admins can delete flights"
ON flights
FOR DELETE
TO authenticated
USING (EXISTS (
  SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin'
));
```
---

⚙️ Custom Admin Function
This function allows only admins to delete flights securely.
```
CREATE OR REPLACE FUNCTION delete_flight(flight_to_delete INT)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  ---
  Verify admin role
  IF NOT EXISTS (
    SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin'
  ) THEN
    RAISE EXCEPTION 'Access denied. Admins only.';
  END IF;

  ---
  Delete flight
  DELETE FROM flights WHERE flight_id = flight_to_delete;
END;
$$;
```
---

🧰 Technologies Used

Supabase (PostgreSQL) — Database and SQL editor

SQL — Schema creation, RLS, and functions

GitHub — Repository hosting and documentation

---

🚀 How to Use

Clone this repository

git clone https://github.com/Awuor-Nancy/Data_Fundamentals_Final_Sem_Project.git


Open Supabase SQL Editor and paste all SQL code.

Insert sample data for flights, passengers, and bookings.

Enable RLS and test with Admin and User accounts.

Run example queries to validate joins and access policies.

Upload evidence:

✅ ERD screenshot

✅ Supabase table views

✅ Policy and function execution proofs

---

📊 Key Learnings

Designed a normalized relational schema to reduce redundancy.

Implemented RLS for secure, multi-user access.

Applied role-based access control with SQL policies.

Practiced joins, aggregations, and security auditing.

Created clear technical documentation for a data project.

---

🧑‍💻 Author

Nancy Anyango — Data Analyst & Developer

📧 Email: anyangnancy@gmail.com

🐙 GitHub: Awuor-Nancy
