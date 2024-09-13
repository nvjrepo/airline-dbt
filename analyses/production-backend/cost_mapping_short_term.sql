/*
------------------------------
CLI statement definition
------------------------------
*/

/*
The logic is defined to create cost table for short-term usage in OLAP schema (dwh).
To execute the script, run below cli, and replace proper value to '[]' areas:
`psql -h [HOST] -p [PORT] -U [USER] -d [DATABASE] -f analyses/production-backend/cost_mapping_short_term.sql`
*/

/*
------------------------------
SQL statement definition
------------------------------
*/

DROP TABLE IF EXISTS dwh.cost_mapping_short_term;
CREATE TABLE dwh.cost_mapping_short_term (
    month           DATE NOT NULL,
    cost_type       VARCHAR(255) NOT NULL,
    rate            NUMERIC NOT NULL,
    unit            VARCHAR(50) NOT NULL,
    fare_condition  VARCHAR(50) NOT NULL,
    aircraft_code   VARCHAR(50) NOT NULL
);

INSERT INTO dwh.cost_mapping_short_term 
    (month, cost_type, rate, unit, fare_condition, aircraft_code)
VALUES 
    ('1970-01-01', 'Fuel Cost', 90, 'km', 'All', 'All'),
    ('1970-01-01', 'Cleaning Cost', 800, 'seat', 'All', 'All'),
    ('1970-01-01', 'Meal Cost', 1000, 'passenger', 'Economy', 'All'),
    ('1970-01-01', 'Meal Cost', 5000, 'passenger', 'Business', 'All');
