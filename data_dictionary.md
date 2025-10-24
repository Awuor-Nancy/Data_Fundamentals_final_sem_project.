# 📘 Data Dictionary

## Table: flights
| Column | Data Type | Description |
|---------|------------|-------------|
| flight_id | SERIAL | Unique flight identifier |
| flight_number | VARCHAR(10) | Flight number (e.g., B6-203) |
| origin | VARCHAR(50) | Departure airport |
| destination | VARCHAR(50) | Arrival airport |
| departure_time | TIMESTAMP | Scheduled departure time |
| arrival_time | TIMESTAMP | Scheduled arrival time |
| status | VARCHAR(20) | Flight status (e.g., On Time, Delayed) |

---

## Table: passengers
| Column | Data Type | Description |
|---------|------------|-------------|
| passenger_id | SERIAL | Unique passenger identifier |
| first_name | VARCHAR(50) | Passenger's first name |
| last_name | VARCHAR(50) | Passenger's last name |
| email | VARCHAR(100) | Contact email |
| loyalty_status | VARCHAR(20) | Loyalty tier (e.g., Blue, Mosaic) |

---

## Table: bookings
| Column | Data Type | Description |
|---------|------------|-------------|
| booking_id | SERIAL | Unique booking ID |
| flight_id | INT | Foreign key linking to flights |
| passenger_id | INT | Foreign key linking to passengers |
| seat_number | VARCHAR(10) | Assigned seat |
| ticket_price | DECIMAL(10,2) | Ticket price |
| booking_date | DATE | Booking date |
