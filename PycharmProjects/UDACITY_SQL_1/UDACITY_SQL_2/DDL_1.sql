--1
CREATE TABLE "employees" (
"emp_id" SERIAL,
"emp_name" TEXT,
"manager_id" INTEGER,
"manager_name" TEXT, -- Correct, phone numbers must be text, not int
"manager_phones" TEXT); -- incorrect, doesnt follow 3NF

--solution:
CREATE TABLE "employees" (
  "id" SERIAL,
  "emp_name" TEXT,
  "manager_id" INTEGER -- regular number.
);
                     --The idea here is that managers are employees,
                     -- so, some rows in employees table will have a manager id
                     -- some will be blank if they are not managers.

CREATE TABLE "employee_phones" (
  "emp_id" INTEGER,
  "phone_number" TEXT
);


--my output:
--postgres=# \dt
--           List of relations
-- Schema |   Name    | Type  |  Owner
----------+-----------+-------+----------
-- public | employees | table | postgres
--(1 row)
--
--postgres=# \d "employees"
--                               Table "public.employees"
--     Column     |  Type   |                         Modifiers
--
------------------+---------+-----------------------------------------------------
---------
-- emp_id         | integer | not null default nextval('employees_emp_id_seq'::reg
--class)
-- emp_name       | text    |
-- manager_id     | integer |
-- manager_name   | text    |
-- manager_phones | text    |



--2
CREATE TABLE "customers"(
"id" SERIAL,
"name" VARCHAR(100) -- split up into 1st and last
);

CREATE TABLE "customer_contact_details"( -- They split emails into a table, and stored the phone no with name
"customer_id" INTEGER,
"email" VARCHAR(100),
"phone_number" VARCHAR(20)
);

CREATE TABLE "rooms"( -- they also added a SERIAL id
"room_number" INTEGER,--smallint
"floor" INTEGER,--smallint
"area_sqft" INTEGER --smallint, up to 32,000
);

CREATE TABLE "reservations"(
"id" BIGSERIAL,
"guest_id" INTEGER,
"check_in" DATE,
"check_out" DATE,
"room_number" INTEGER
);


--Solutions:

--CREATE TABLE "customers" (
--  "id" SERIAL,
--  "first_name" VARCHAR,
--  "last_name" VARCHAR,
--  "phone_number" VARCHAR
--);
--
--CREATE TABLE "customer_emails" (
--  "customer_id" INTEGER,
--  "email_address" VARCHAR
--);

--CREATE TABLE "reservations" (
--  "id" SERIAL,
--  "customer_id" INTEGER,
--  "room_id" INTEGER,
--  "check_in" DATE,
--  "check_out" DATE
--);


