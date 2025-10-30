
# 🛫 JetBlue Flight Booking System

- A Supabase + SQL + R (Posit Cloud) powered airline management system that allows administrators and users to manage flights, bookings, and passengers securely using Role-Based Access Control (RLS).
---

## 📚 Table of Contents
- [Overview](#-overview)
- [Features](#-features)
- [Database Schema](#-database-schema)
- [Entity-Relationship Diagram (ERD)](#-entity-relationship-diagram-erd)
- [Data Dictionary](#-data-dictionary)
- [Row-Level Security (RLS) Policies](#-row-level-security-rls-policies)
- [User Roles & Permissions](#-user-roles--permissions)
- [Custom SQL Functions](#-custom-sql-functions)
- [R & Posit Cloud Integration](#-r--posit-cloud-integration)
- [Setup Instructions](#-setup-instructions)
- [License](#-license)

---

## 🧩 Overview

The JetBlue Flight Booking System enables secure management of:

- ✈️ Flight scheduling

- 👥 Passenger records

- 🎫 Booking details

It uses Supabase for authentication and PostgreSQL database management, while R (Posit Cloud) was used for data exploration and visualization when the API connection was unstable.
--- 

## ✨ Features

✅ Role-based access control (Admin / User)

✅ Row-Level Security (RLS) for restricted access

✅ CRUD operations with SQL

✅ Custom admin-only functions

✅ Supabase Auth integration

✅ R data analysis and visualization on Posit Cloud

✅ Clean schema with ERD and documentation

---

## 🧱 Database Schema

| Table          | Description                                                   |
| -------------- | ------------------------------------------------------------- |
| **flights**    | Stores flight details and status.                             |
| **passengers** | Stores passenger information linked to users.                 |
| **bookings**   | Connects passengers to flights with booking details.          |
| **users**      | Manages user roles (`admin`, `user`) linked to Supabase Auth. |
---

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

### 🖼️ Table Screenshots
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

- bookings.flight_id → flights.flight_id → (One flight → Many bookings)

- bookings.passenger_id → passengers.passenger_id → (One passenger → Many bookings)

➡️ Result: Many-to-Many relationship between flights and passengers through bookings.

## 🧩 ERD (Entity Relationship Diagram)
<p align="center"> <img width="1177" height="736" alt="ERD Diagram" src="https://github.com/user-attachments/assets/fc45842f-e8c3-4533-8985-2692f8c6e679" /> </p>

### 🧮 Example Queries

1️⃣ List all upcoming flights
```
SELECT flight_number, origin, destination, departure_time, status
FROM flights
ORDER BY departure_time;
```

2️⃣ Find bookings for a passenger named 'Santos'
```
SELECT p.first_name, p.last_name, f.flight_number, f.destination, b.seat_number, b.ticket_price
FROM bookings b
JOIN passengers p ON b.passenger_id = p.passenger_id
JOIN flights f ON b.flight_id = f.flight_id
WHERE p.last_name = 'Santos';
```

3️⃣ Count total passengers per flight
```
SELECT f.flight_number, COUNT(b.booking_id) AS total_bookings
FROM bookings b
JOIN flights f ON f.flight_id = b.flight_id
GROUP BY f.flight_number
ORDER BY total_bookings DESC;
```

4️⃣ Average ticket price by route
```
SELECT f.origin, f.destination, ROUND(AVG(b.ticket_price), 2) AS avg_ticket_price
FROM bookings b
JOIN flights f ON f.flight_id = b.flight_id
GROUP BY f.origin, f.destination;
```

---
## 🔐 Security & RLS Setup
✅ Enable Row-Level Security
```
ALTER TABLE flights ENABLE ROW LEVEL SECURITY;
ALTER TABLE passengers ENABLE ROW LEVEL SECURITY;
ALTER TABLE bookings ENABLE ROW LEVEL SECURITY;
```

---
✅ Create User Roles Table
```
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
```

---
🧠 Roles and Policies
👩‍✈️ Admin Role

- Admins have full access — can read, insert, update, and delete any record.

👤 User Role

- Regular users have restricted access — can view or insert only their own data.

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

## 🧩 R & Posit Cloud Integration (Data Analysis)

Because of network restrictions, the Supabase API connection failed in RStudio using the RPostgres library (Error: Network is unreachable).
To proceed with analysis, I:

1. Exported all Supabase tables (flights, passengers, bookings) as .csv files.

2. Uploaded them to Posit Cloud for local analysis.

3. Used R libraries like dplyr, ggplot2, and readr to explore and visualize data.

---

### LOAD LIBRARIES

install.packages("tidyverse")  # run once only
library(tidyverse)

---
```
### LOAD DATA

flights <- read_csv("flights_rows.csv")
bookings <- read_csv("bookings_rows.csv")
passengers <- read_csv("passengers_rows.csv")

---
### TOTAL BOOKINGS PER FLIGHT

bookings_summary <- bookings %>%
  group_by(flight_id) %>%
  summarise(total_bookings = n()) %>%
  left_join(flights, by = "flight_id")

ggplot(bookings_summary, aes(x = flight_number, y = total_bookings)) +
  geom_col(fill = "steelblue") +
  labs(
    title = "Total Bookings per Flight",
    x = "Flight Number",
    y = "Number of Bookings"
  ) +
  theme_minimal()

---
### BOOKINGS PER DESTINATION

bookings_per_destination <- bookings %>%
  left_join(flights, by = "flight_id") %>%
  group_by(destination) %>%
  summarise(total_bookings = n()) %>%
  arrange(desc(total_bookings))

ggplot(bookings_per_destination, aes(x = reorder(destination, total_bookings), y = total_bookings)) +
  geom_col(fill = "#0077B6") +
  coord_flip() +
  labs(
    title = "🌍 Total Bookings per Destination",
    x = "Destination",
    y = "Bookings"
  ) +
  theme_minimal()

---
### TICKET PRICE DISTRIBUTION

ggplot(bookings, aes(x = ticket_price)) +
  geom_histogram(binwidth = 50, fill = "#00AEEF", color = "black", alpha = 0.7) +
  labs(
    title = "🎫 Ticket Price Distribution",
    x = "Ticket Price (USD)",
    y = "Number of Bookings"
  ) +
  theme_minimal()
---
### FLIGHT STATUS COUNTS

status_summary <- flights %>%
  group_by(status) %>%
  summarise(total_flights = n())

ggplot(status_summary, aes(x = status, y = total_flights, fill = status)) +
  geom_col(show.legend = FALSE) +
  labs(
    title = "✈️ Flight Status Overview",
    x = "Flight Status",
    y = "Number of Flights"
  ) +
  theme_minimal()
  ```

  ---

  ## 📊 Screenshots for Visualization using R
  
  - Ticket Price Distribution (ggplot2)
<p align="center"> <img width="1392" height="755" alt="image" src="https://github.com/user-attachments/assets/8776b846-b96c-498c-9526-cde671ce2d68" />
</p>

  - Bookings per Destination
<p align="center"> <img width="1381" height="769" alt="image" src="https://github.com/user-attachments/assets/12913a02-6358-4ed1-ac4a-a094611c343e" />
 </p>

  - Flight Status Count
<p align="center"> <img width="1382" height="759" alt="image" src="https://github.com/user-attachments/assets/3596aa88-0e2e-4816-9ee3-5a0dc40f3a27" />
 </p>
  

## 🧰 Technologies Used
---

| Tool            | Purpose                         |
| --------------- | ------------------------------- |
| Supabase        | Database hosting & RLS security |
| PostgreSQL      | Data storage                    |
| SQL             | Schema, joins, policies         |
| R (Posit Cloud) | Data analysis & visualization   |
| GitHub          | Documentation and submission    |


---

## 🚀 How to Use

1. Clone this repository

`` git clone https://github.com/Awuor-Nancy/Data_Fundamentals_Final_Sem_Project.git
``

2. Set up the database in Supabase

- Open the SQL Editor in Supabase.

- Paste the contents of schema.sql and run to create all tables:

- flights

- passengers

- bookings

Optionally insert sample data or export data as .csv for use in R.

3 .(Alternative) Upload data manually to Posit Cloud (RStudio Cloud)

Since the API connection to Supabase was restricted, the data was exported as CSVs:

- flights_rows.csv

- passengers_rows.csv

- bookings_rows.csv

These were uploaded to Posit Cloud (RStudio Cloud) for analysis.

4. Analyze data in R (Posit Cloud)

Install the required packages:

install.packages(c("DBI", "RPostgres", "dplyr", "ggplot2"))


Load the datasets:

``
flights <- read.csv("flights_rows.csv")
passengers <- read.csv("passengers_rows.csv")
bookings <- read.csv("bookings_rows.csv")
``


Perform data analysis and visualization, for example:

`` # Total bookings per flight
library(dplyr)
bookings_summary <- bookings %>%
  group_by(flight_id) %>%
  summarise(total_bookings = n()) %>%
  left_join(flights, by = "flight_id")
  ``

`` # Plot: Total Bookings per Flight
library(ggplot2)
ggplot(bookings_summary, aes(x = flight_number, y = total_bookings)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  labs(title = "Total Bookings per Flight", x = "Flight Number", y = "Bookings") +
  theme_minimal()
  ``


Additional analyses done in R:

🎟️ Ticket Price Distribution

🌍 Bookings per Destination

✈️ Flight Status Counts
---

5. View outputs and visualizations

Visualizations were generated using ggplot2.

Example screenshots are included:

analysed_data.png — Data analysis in Posit Cloud

ggplot2.png — Visualization of flight bookings
---

6. Upload Images

✅ ERD screenshot

✅ Supabase schema and SQL setup

✅ CSV tables used in R

✅ RStudio (Posit Cloud) analysis screenshots
---

📊 Key Learnings

- Designed a normalized relational schema to minimize redundancy.

- Practiced data migration and integration between Supabase and R (Posit Cloud).

- Applied data wrangling and summarization with dplyr.

- Built visual insights using ggplot2 to show booking patterns and ticket pricing.

- Handled connection limitations by switching from live SQL queries to CSV-based analysis.

- Created clear, professional documentation combining SQL + R data analysis.

🧑‍💻 Author

Nancy Anyango — Data Analyst & Developer
📧 Email: anyangnancy@gmail.com

🐙 GitHub: Awuor-Nancy
