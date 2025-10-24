# ✈️ Data_Fundamentals_final_sem_project — JetBlue Flight Booking System

## 📘 Project Purpose
This project demonstrates database design and query skills using **Supabase (PostgreSQL)**.  
It models a simplified flight booking system for **JetBlue Airlines**, focusing on data normalization, relationships, and real-world queries.

---

## 🗂️ Schema Overview

The database includes three main tables:

| Table | Description |
|-------|--------------|
| **flights** | Stores flight details (flight number, route, aircraft type, and status). |
| **passengers** | Contains passenger data, including contact and loyalty information. |
| **bookings** | Connects passengers to flights with details like seat number, price, and booking date. |

### 🔗 Relationships
- Each **booking** references **one flight** (`flight_id`)
- Each **booking** references **one passenger** (`passenger_id`)
- The relationship between passengers and flights is **many-to-many** via bookings.

---

## 🧩 ERD (Entity Relationship Diagram)
The ERD below shows table relationships and keys.

📁 Located in: `docs/ERD.png`

---

## 🧮 Example Queries

```sql
-- View all upcoming flights
SELECT flight_number, origin, destination, departure_time, status
FROM flights
ORDER BY departure_time;

-- View all bookings for a specific passenger
SELECT p.first_name, p.last_name, f.flight_number, f.destination, b.seat_number, b.ticket_price
FROM bookings b
JOIN passengers p ON b.passenger_id = p.passenger_id
JOIN flights f ON b.flight_id = f.flight_id
WHERE p.last_name = 'Santos';

-- Count total passengers per flight
SELECT f.flight_number, COUNT(b.booking_id) AS total_bookings
FROM bookings b
JOIN flights f ON f.flight_id = b.flight_id
GROUP BY f.flight_number;
