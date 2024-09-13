/*
------------------------------
CLI statement definition
------------------------------
*/

/*
The logic is defined to create cost table for long-term usage in OLAP schema (dwh).
To execute the script, run below cli, and replace proper value to '[]' areas:
`psql -h [HOST] -p [PORT] -U [USER] -d [DATABASE] -f analyses/production-backend/cost_mapping_long_term.sql`
*/

/*
------------------------------
SQL statement definition
------------------------------
*/

DROP TABLE IF EXISTS dwh.cost_mapping_long_term;
CREATE TABLE dwh.cost_mapping_long_term (
    cost_type_id     SERIAL PRIMARY KEY,
    cost_type        VARCHAR(255) NOT NULL,
    rate             NUMERIC NOT NULL,
    created_at       TIMESTAMPTZ NOT NULL,
    updated_at       TIMESTAMPTZ NOT NULL,
    effective_from   DATE NOT NULL,
    effective_to     DATE NOT NULL,
    cost_criteria    JSONB NOT NULL
);

-- Insert data
INSERT INTO dwh.cost_mapping_long_term
    (cost_type_id, cost_type, rate, created_at, updated_at, effective_from, effective_to, cost_criteria)
VALUES
    (1, 'Fuel Cost', 90, '2024-09-13 12:00:00', '2024-09-13 12:00:00', '2024-09-01', '2024-12-31',
        '{"unit": "km"}'),
    (2, 'Cleaning Cost', 800, '2024-09-13 12:00:00', '2024-09-13 12:00:00', '2024-09-01', '2024-12-31',
        '{"unit": "seat"}'),
    (3, 'Meal Cost (Economy)', 1000, '2024-09-13 12:00:00', '2024-09-13 12:00:00', '2024-09-01', '2024-12-31',
        '{"unit": "meal", "fare_condition": "Economy"}'),
    (4, 'Meal Cost (Business)', 5000, '2024-09-13 12:00:00', '2024-09-13 12:00:00', '2024-09-01', '2024-12-31',
        '{"unit": "meal", "fare_condition": "Business"}');
