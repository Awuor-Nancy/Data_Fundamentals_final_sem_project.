# 📘 Data Dictionary — JetBlue Flight Booking System

This data dictionary provides detailed descriptions of all tables and columns in the **JetBlue Flight Booking System** database.  
It serves as a reference for developers, analysts, and reviewers to understand the schema structure and data relationships.

---

## 🛫 Table: `flights`

| **Column**       | **Data Type**   | **Description** |
|------------------|-----------------|-----------------|
| `flight_id`      | `SERIAL`        | Unique flight identifier (auto-incremented primary key). |
| `flight_number`  | `VARCHAR(10)`   | Unique flight number (e.g., `JB203`). |
| `origin`         | `VARCHAR(50)`   | Departure airport or city (e.g., `Nairobi`). |
| `destination`    | `VARCHAR(50)`   | Arrival airport or city (e.g., `New York`). |
| `departure_time` | `TIMESTAMP`     | Scheduled flight departure date and time. |
| `arrival_time`   | `TIMESTAMP`     | Scheduled flight arrival date and time. |
| `status`         | `VARCHAR(20)`   | Current flight status (`Scheduled`, `On Time`, `Delayed`, etc.). |

🧩 **Notes:**
- Each `flight_id` links to multiple records in the `bookings` table.
- Flight numbers are unique per scheduled route and time.

---

## 🧍 Table: `passengers`

| **Column**       | **Data Type**   | **Description** |
|------------------|-----------------|-----------------|
| `passenger_id`   | `SERIAL`        | Unique passenger identifier (auto-incremented primary key). |
| `first_name`     | `VARCHAR(50)`   | Passenger’s given name. |
| `last_name`      | `VARCHAR(50)`   | Passenger’s surname. |
| `email`          | `VARCHAR(100)`  | Passenger’s contact email (unique). |
| `loyalty_status` | `VARCHAR(20)`   | Loyalty program level (`Standard`, `Silver`, `Gold`). |

🧩 **Notes:**
- Passenger email must be unique across the system.  
- Loyalty status can be used for marketing, upgrades, and analytics.

---

## 🎫 Table: `bookings`

| **Column**       | **Data Type**   | **Description** |
|------------------|-----------------|-----------------|
| `booking_id`     | `SERIAL`        | Unique booking identifier (auto-incremented primary key). |
| `flight_id`      | `INT`           | Foreign key referencing `flights(flight_id)`. |
| `passenger_id`   | `INT`           | Foreign key referencing `passengers(passenger_id)`. |
| `seat_number`    | `VARCHAR(10)`   | Assigned seat for the passenger (e.g., `12A`). |
| `ticket_price`   | `DECIMAL(10,2)` | Flight ticket price (in USD). |
| `booking_date`   | `DATE`          | Date when the booking was made (defaults to `CURRENT_DATE`). |

🧩 **Notes:**
- A single passenger can have multiple bookings across flights.  
- Each booking uniquely links one passenger to one flight.  
- `ON DELETE CASCADE` ensures that when a flight or passenger is deleted, related bookings are automatically removed.

---

## 👥 Table: `users` (for Role-Based Access)

| **Column** | **Data Type** | **Description** |
|-------------|----------------|----------------|
| `id` | `UUID` | Unique user identifier linked to Supabase Auth (`auth.uid()`). |
| `email` | `TEXT` | User login email (must be unique). |
| `role` | `TEXT` | Role type: `'admin'` or `'user'`. Default is `'user'`. |

🧩 Notes:

Used for role-based access control (RLS).

Admins can run special functions like deleting flights or bookings.

🧩 **Notes:**
- Admins have full CRUD access across all tables.  
- Regular users have limited access controlled by Row-Level Security (RLS) policies.

---
🧠 Functions (Custom Admin Actions)
| **Function**                          | **Purpose**               | **Access**  |
| ------------------------------------- | ------------------------- | ----------- |
| `delete_booking(booking_id INT)`      | Deletes a booking record. | Admin only. |
| `delete_flight(flight_to_delete INT)` | Deletes a flight record.  | Admin only. |
---
.
🔒 Security (Row-Level Security Policies)
| **Policy**                 | **Table**                           | **Access** | **Description**                                          |
| -------------------------- | ----------------------------------- | ---------- | -------------------------------------------------------- |
| Users view/insert own data | `passengers`, `bookings`            | User       | Authenticated users can only view or add their own data. |
| Admins manage all          | `flights`, `passengers`, `bookings` | Admin      | Admins can perform all CRUD actions.                     |
| RLS enabled                | All main tables                     | —          | Secures all access through Supabase policies.            |

----

✅ **Summary of Relationships**

| Relationship | Type | Description |
|---------------|------|-------------|
| `flights` → `bookings` | 1 → Many | A flight can have multiple bookings. |
| `passengers` → `bookings` | 1 → Many | A passenger can book multiple flights. |
| `users` | Auth | Controls who can access or modify data. |

🪪 Roles Overview

| **Role** | **Access Level** | **Capabilities**                                              |
| -------- | ---------------- | ------------------------------------------------------------- |
| `admin`  | Full             | Can create, update, delete any flight, booking, or passenger. |
| `user`   | Restricted       | Can only view or insert their own passenger and booking data. |


