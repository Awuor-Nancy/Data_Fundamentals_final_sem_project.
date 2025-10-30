-- =======================================================
-- ✈️ JetBlue Flight Booking System — Supabase Schema
-- =======================================================

-- Enable pgcrypto for UUID generation
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- =======================================================
-- 🛫 Flights Table
-- =======================================================
CREATE TABLE flights (
  flight_id SERIAL PRIMARY KEY,
  flight_number VARCHAR(10),
  origin VARCHAR(50),
  destination VARCHAR(50),
  departure_time TIMESTAMP,
  arrival_time TIMESTAMP,
  status VARCHAR(20)
);

-- =======================================================
-- 🧍 Passengers Table
-- =======================================================
CREATE TABLE passengers (
  passenger_id SERIAL PRIMARY KEY,
  first_name VARCHAR(50),
  last_name VARCHAR(50),
  email VARCHAR(100) UNIQUE,
  loyalty_status VARCHAR(20),
  user_id UUID REFERENCES auth.users(id)  -- link to Supabase Auth user
);

-- =======================================================
-- 🎫 Bookings Table
-- =======================================================
CREATE TABLE bookings (
  booking_id SERIAL PRIMARY KEY,
  flight_id INT REFERENCES flights(flight_id) ON DELETE CASCADE,
  passenger_id INT REFERENCES passengers(passenger_id) ON DELETE CASCADE,
  seat_number VARCHAR(10),
  ticket_price DECIMAL(10,2),
  booking_date DATE DEFAULT CURRENT_DATE
);

-- =======================================================
-- 👥 Custom Users Table (Role Management)
-- =======================================================
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email TEXT UNIQUE NOT NULL,
  role TEXT CHECK (role IN ('admin', 'user')) DEFAULT 'user'
);

-- =======================================================
-- 💾 Sample Data
-- =======================================================
INSERT INTO users (id, email, role)
VALUES 
  (gen_random_uuid(), 'admin@jetblue.com', 'admin'),
  (gen_random_uuid(), 'nancy@jetblue.com', 'user'),
  (gen_random_uuid(), 'barnabas@jetblue.com', 'user');

-- =======================================================
-- 🔐 Enable Row-Level Security (RLS)
-- =======================================================
ALTER TABLE flights ENABLE ROW LEVEL SECURITY;
ALTER TABLE passengers ENABLE ROW LEVEL SECURITY;
ALTER TABLE bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- =======================================================
-- 🧠 RLS POLICIES
-- =======================================================

-- -------------------------------
-- 🧍 PASSENGERS TABLE POLICIES
-- -------------------------------
CREATE POLICY "Users view own passenger record"
ON passengers
FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

CREATE POLICY "Users insert own passenger record"
ON passengers
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Admins manage all passengers"
ON passengers
FOR ALL
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin'
  )
);

-- -------------------------------
-- 🎫 BOOKINGS TABLE POLICIES
-- -------------------------------
CREATE POLICY "Users view own bookings"
ON bookings
FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM passengers WHERE passengers.passenger_id = bookings.passenger_id
    AND passengers.user_id = auth.uid()
  )
);

CREATE POLICY "Users insert own bookings"
ON bookings
FOR INSERT
TO authenticated
WITH CHECK (
  EXISTS (
    SELECT 1 FROM passengers WHERE passengers.passenger_id = bookings.passenger_id
    AND passengers.user_id = auth.uid()
  )
);

CREATE POLICY "Admins manage all bookings"
ON bookings
FOR ALL
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin'
  )
);

-- -------------------------------
-- ✈️ FLIGHTS TABLE POLICIES
-- -------------------------------
CREATE POLICY "Admins manage all flights"
ON flights
FOR ALL
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin'
  )
);

-- =======================================================
-- ⚙️ ADMIN-ONLY FUNCTIONS
-- =======================================================

-- Delete a booking (Admins only)
CREATE OR REPLACE FUNCTION delete_booking(booking_id INT)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin'
  ) THEN
    RAISE EXCEPTION 'Access denied. Admins only.';
  END IF;

  DELETE FROM bookings WHERE bookings.booking_id = delete_booking.booking_id;
END;
$$;

-- Delete a flight (Admins only)
CREATE OR REPLACE FUNCTION delete_flight(flight_to_delete INT)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin'
  ) THEN
    RAISE EXCEPTION 'Access denied. Admins only.';
  END IF;

  DELETE FROM flights WHERE flight_id = flight_to_delete;
END;
$$;

-- =======================================================
-- ✅ END OF SCHEMA
-- =======================================================
