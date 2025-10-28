# ✈️ Data_Fundamentals_Final_Sem_Project — JetBlue Flight Booking System

<div align="center">
  <img width="120" height="55" alt="JetBlue Logo" src="https://github.com/user-attachments/assets/5edb3297-2f15-4111-8a8b-56c199137dd7" />
</div>

---

## 📖 Table of Contents  
- [📘 Project Purpose](#-project-purpose)  
- [🗂️ Schema Overview](#-schema-overview)  
- [🔗 Relationships](#-relationships)  
- [🧩 ERD (Entity-Relationship-Diagram)](#-erd-entity-relationship-diagram)  
- [🧮 Example Queries](#-example-queries)  
- [🔐 Security & RLS Setup](#-security--rls-setup)  
- [🧠 Roles and Policies](#-roles-and-policies)  
- [⚙️ Custom Admin Function](#-custom-admin-function)  
- [🧰 Technologies Used](#-technologies-used)  
- [🚀 How to Use](#-how-to-use)  
- [📊 Key Learnings](#-key-learnings)  
- [🧑‍💻 Author](#-author)  

---

## 📘 Project Purpose  
This project demonstrates a **JetBlue Flight Booking System** built using **Supabase (PostgreSQL)**.  

**Objectives:**  
- Design and normalize a relational database.  
- Implement **Row Level Security (RLS)** with Admin and User roles.  
- Build SQL queries for realistic airline use cases.  
- Showcase security policies and SQL functions.  

---

## 🗂️ Schema Overview  

| Table | Description |
|--------|--------------|
| **flights** | Contains flight schedules and operational details. |
| **passengers** | Stores passenger details including name, email, and loyalty status. |
| **bookings** | Links passengers to flights, storing seat and ticket information. |

### 🧱 SQL Definitions

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

---

🔗 Relationships

bookings.flight_id → flights.flight_id → (One flight → Many bookings)

bookings.passenger_id → passengers.passenger_id → (One passenger → Many bookings)

➡️ Result: Many-to-Many relationship between flights and passengers through bookings.

🧩 ERD (Entity Relationship Diagram)

Visual representation of tables and relationships:

📎 Include your ERD image in docs/ERD.png or update the path below.

![ERD Diagram](<img width="1177" height="736" alt="image" src="https://github.com/user-attachments/assets/9a0b3597-1bdb-4ee8-bb2c-f6156dc741c5" />)


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
