
---

### **3️⃣ Create `schema.sql`**

This file contains:
- `CREATE TABLE` commands
- (Optional) inserts or example queries
- Screenshots showing tables in Supabase

Example:

```sql
-- SCHEMA: JetBlue Flight Booking System

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

-- You can add screenshots below (Markdown format)
-- ![Flights Table](docs/screenshots/flights_table.png)
-- ![Passengers Table](docs/screenshots/passengers_table.png)
-- ![Bookings Table](docs/screenshots/bookings_table.png)
