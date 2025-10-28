---

# **3️⃣ Create `schema.sql`**

This file defines the **JetBlue Flight Booking System** database schema used in Supabase.

## 📦 Contents
- `CREATE TABLE` commands for all core entities  
- Optional sample data inserts  
- Screenshot placeholders for visual proof  

---

### 🧱 Example `schema.sql` File

```sql
-- ==============================================
-- ✈️ SCHEMA: JetBlue Flight Booking System
-- ==============================================

-- Enable required extension for UUID generation
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- -----------------------------
-- 🛫 Flights Table
-- -----------------------------
CREATE TABLE flights (
  flight_id SERIAL PRIMARY KEY,
  flight_number VARCHAR(10) NOT NULL,
  origin VARCHAR(50) NOT NULL,
  destination VARCHAR(50) NOT NULL,
  departure_time TIMESTAMP NOT NULL,
  arrival_time TIMESTAMP NOT NULL,
  status VARCHAR(20) DEFAULT 'Scheduled'
);

-- -----------------------------
-- 🧍 Passengers Table
-- -----------------------------
CREATE TABLE passengers (
  passenger_id SERIAL PRIMARY KEY,
  first_name VARCHAR(50) NOT NULL,
  last_name VARCHAR(50) NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL,
  loyalty_status VARCHAR(20) DEFAULT 'Standard'
);

-- -----------------------------
-- 🎫 Bookings Table
-- -----------------------------
CREATE TABLE bookings (
  booking_id SERIAL PRIMARY KEY,
  flight_id INT REFERENCES flights(flight_id) ON DELETE CASCADE,
  passenger_id INT REFERENCES passengers(passenger_id) ON DELETE CASCADE,
  seat_number VARCHAR(10),
  ticket_price DECIMAL(10,2),
  booking_date DATE DEFAULT CURRENT_DATE
);

-- -----------------------------
-- 👥 Users Table (For RLS & Roles)
-- -----------------------------
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email TEXT UNIQUE NOT NULL,
  role TEXT CHECK (role IN ('admin', 'user')) DEFAULT 'user'
);

-- -----------------------------
-- 💾 Sample Data Inserts
-- -----------------------------
INSERT INTO users (id, email, role) VALUES
  (gen_random_uuid(), 'admin@jetblue.com', 'admin'),
  (gen_random_uuid(), 'anyangnancy@gmail.com', 'user'),
  (gen_random_uuid(), 'awuornancy66@gmail.com', 'user');

INSERT INTO flights (flight_number, origin, destination, departure_time, arrival_time, status)
VALUES
  ('JB101', 'Nairobi', 'New York', '2025-11-01 09:00:00', '2025-11-01 18:00:00', 'Scheduled'),
  ('JB202', 'Mombasa', 'Boston', '2025-11-02 10:30:00', '2025-11-02 19:15:00', 'Scheduled');

INSERT INTO passengers (first_name, last_name, email, loyalty_status)
VALUES
  ('Nancy', 'Anyango', 'anyangnancy@gmail.com', 'Gold'),
  ('Barnabas', 'Otieno', 'barnabas@jetblue.com', 'Silver');

INSERT INTO bookings (flight_id, passenger_id, seat_number, ticket_price)
VALUES
  (1, 1, '12A', 850.00),
  (2, 2, '14B', 720.00);
