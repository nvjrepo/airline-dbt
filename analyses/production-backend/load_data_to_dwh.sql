/*
------------------------------
CLI statement definition
------------------------------
*/

/*
The logic is defined to clone tables and relevant information from backend schema (bookings) to OLAP schema (dwh).
To execute the script, run below cli, and replace proper value to '[]' areas:
`psql -h [HOST] -p [PORT] -U [USER] -d [DATABASE] -f analyses/production-backend/load_data_to_dwh.sql`
*/

/*
------------------------------
SQL statement definition
------------------------------
*/
DROP SCHEMA IF EXISTS dwh CASCADE;
CREATE SCHEMA dwh;


--
-- Name: SCHEMA dwh; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA dwh IS 'OLAP database schema, clone from `dwh` schema';


SET search_path = dwh, pg_catalog;

--
-- Name: lang(); Type: FUNCTION; Schema: dwh; Owner: -
--

CREATE FUNCTION lang() RETURNS text
    LANGUAGE plpgsql STABLE
    AS $$
BEGIN
  RETURN current_setting('dwh.lang');
EXCEPTION
  WHEN undefined_object THEN
    RETURN NULL;
END;
$$;


--
-- Name: now(); Type: FUNCTION; Schema: dwh; Owner: -
--

CREATE FUNCTION now() RETURNS timestamp with time zone
    LANGUAGE sql IMMUTABLE
    AS $$SELECT '2017-08-15 18:00:00'::TIMESTAMP AT TIME ZONE 'Europe/Moscow';$$;


--
-- Name: FUNCTION now(); Type: COMMENT; Schema: dwh; Owner: -
--

COMMENT ON FUNCTION now() IS 'Point in time according to which the data are generated';


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: aircrafts_data; Type: TABLE; Schema: dwh; Owner: -
--

CREATE TABLE aircrafts_data (
    aircraft_code character(3) NOT NULL,
    model jsonb NOT NULL,
    range integer NOT NULL,
    CONSTRAINT aircrafts_range_check CHECK ((range > 0))
);


--
-- Name: TABLE aircrafts_data; Type: COMMENT; Schema: dwh; Owner: -
--

COMMENT ON TABLE aircrafts_data IS 'Aircrafts (internal data)';


--
-- Name: COLUMN aircrafts_data.aircraft_code; Type: COMMENT; Schema: dwh; Owner: -
--

COMMENT ON COLUMN aircrafts_data.aircraft_code IS 'Aircraft code, IATA';


--
-- Name: COLUMN aircrafts_data.model; Type: COMMENT; Schema: dwh; Owner: -
--

COMMENT ON COLUMN aircrafts_data.model IS 'Aircraft model';


--
-- Name: COLUMN aircrafts_data.range; Type: COMMENT; Schema: dwh; Owner: -
--

COMMENT ON COLUMN aircrafts_data.range IS 'Maximal flying distance, km';

--
-- Name: airports_data; Type: TABLE; Schema: dwh; Owner: -
--

CREATE TABLE airports_data (
    airport_code character(3) NOT NULL,
    airport_name jsonb NOT NULL,
    city jsonb NOT NULL,
    coordinates point NOT NULL,
    timezone text NOT NULL
);


--
-- Name: TABLE airports_data; Type: COMMENT; Schema: dwh; Owner: -
--

COMMENT ON TABLE airports_data IS 'Airports (internal data)';


--
-- Name: COLUMN airports_data.airport_code; Type: COMMENT; Schema: dwh; Owner: -
--

COMMENT ON COLUMN airports_data.airport_code IS 'Airport code';


--
-- Name: COLUMN airports_data.airport_name; Type: COMMENT; Schema: dwh; Owner: -
--

COMMENT ON COLUMN airports_data.airport_name IS 'Airport name';


--
-- Name: COLUMN airports_data.city; Type: COMMENT; Schema: dwh; Owner: -
--

COMMENT ON COLUMN airports_data.city IS 'City';


--
-- Name: COLUMN airports_data.coordinates; Type: COMMENT; Schema: dwh; Owner: -
--

COMMENT ON COLUMN airports_data.coordinates IS 'Airport coordinates (longitude and latitude)';


--
-- Name: COLUMN airports_data.timezone; Type: COMMENT; Schema: dwh; Owner: -
--

COMMENT ON COLUMN airports_data.timezone IS 'Airport time zone';

--
-- Name: boarding_passes; Type: TABLE; Schema: dwh; Owner: -
--

CREATE TABLE boarding_passes (
    ticket_no character(13) NOT NULL,
    flight_id integer NOT NULL,
    boarding_no integer NOT NULL,
    seat_no character varying(4) NOT NULL
);


--
-- Name: TABLE boarding_passes; Type: COMMENT; Schema: dwh; Owner: -
--

COMMENT ON TABLE boarding_passes IS 'Boarding passes';


--
-- Name: COLUMN boarding_passes.ticket_no; Type: COMMENT; Schema: dwh; Owner: -
--

COMMENT ON COLUMN boarding_passes.ticket_no IS 'Ticket number';


--
-- Name: COLUMN boarding_passes.flight_id; Type: COMMENT; Schema: dwh; Owner: -
--

COMMENT ON COLUMN boarding_passes.flight_id IS 'Flight ID';


--
-- Name: COLUMN boarding_passes.boarding_no; Type: COMMENT; Schema: dwh; Owner: -
--

COMMENT ON COLUMN boarding_passes.boarding_no IS 'Boarding pass number';


--
-- Name: COLUMN boarding_passes.seat_no; Type: COMMENT; Schema: dwh; Owner: -
--

COMMENT ON COLUMN boarding_passes.seat_no IS 'Seat number';


--
-- Name: bookings; Type: TABLE; Schema: dwh; Owner: -
--

CREATE TABLE bookings (
    book_ref character(6) NOT NULL,
    book_date timestamp with time zone NOT NULL,
    total_amount numeric(10,2) NOT NULL
);


--
-- Name: TABLE bookings; Type: COMMENT; Schema: dwh; Owner: -
--

COMMENT ON TABLE bookings IS 'bookings';


--
-- Name: COLUMN bookings.book_ref; Type: COMMENT; Schema: dwh; Owner: -
--

COMMENT ON COLUMN bookings.book_ref IS 'Booking number';


--
-- Name: COLUMN bookings.book_date; Type: COMMENT; Schema: dwh; Owner: -
--

COMMENT ON COLUMN bookings.book_date IS 'Booking date';


--
-- Name: COLUMN bookings.total_amount; Type: COMMENT; Schema: dwh; Owner: -
--

COMMENT ON COLUMN bookings.total_amount IS 'Total booking cost';


--
-- Name: flights; Type: TABLE; Schema: dwh; Owner: -
--

CREATE TABLE flights (
    flight_id integer NOT NULL,
    flight_no character(6) NOT NULL,
    scheduled_departure timestamp with time zone NOT NULL,
    scheduled_arrival timestamp with time zone NOT NULL,
    departure_airport character(3) NOT NULL,
    arrival_airport character(3) NOT NULL,
    status character varying(20) NOT NULL,
    aircraft_code character(3) NOT NULL,
    actual_departure timestamp with time zone,
    actual_arrival timestamp with time zone,
    CONSTRAINT flights_check CHECK ((scheduled_arrival > scheduled_departure)),
    CONSTRAINT flights_check1 CHECK (((actual_arrival IS NULL) OR ((actual_departure IS NOT NULL) AND (actual_arrival IS NOT NULL) AND (actual_arrival > actual_departure)))),
    CONSTRAINT flights_status_check CHECK (((status)::text = ANY (ARRAY[('On Time'::character varying)::text, ('Delayed'::character varying)::text, ('Departed'::character varying)::text, ('Arrived'::character varying)::text, ('Scheduled'::character varying)::text, ('Cancelled'::character varying)::text])))
);


--
-- Name: TABLE flights; Type: COMMENT; Schema: dwh; Owner: -
--

COMMENT ON TABLE flights IS 'Flights';


--
-- Name: COLUMN flights.flight_id; Type: COMMENT; Schema: dwh; Owner: -
--

COMMENT ON COLUMN flights.flight_id IS 'Flight ID';


--
-- Name: COLUMN flights.flight_no; Type: COMMENT; Schema: dwh; Owner: -
--

COMMENT ON COLUMN flights.flight_no IS 'Flight number';


--
-- Name: COLUMN flights.scheduled_departure; Type: COMMENT; Schema: dwh; Owner: -
--

COMMENT ON COLUMN flights.scheduled_departure IS 'Scheduled departure time';


--
-- Name: COLUMN flights.scheduled_arrival; Type: COMMENT; Schema: dwh; Owner: -
--

COMMENT ON COLUMN flights.scheduled_arrival IS 'Scheduled arrival time';


--
-- Name: COLUMN flights.departure_airport; Type: COMMENT; Schema: dwh; Owner: -
--

COMMENT ON COLUMN flights.departure_airport IS 'Airport of departure';


--
-- Name: COLUMN flights.arrival_airport; Type: COMMENT; Schema: dwh; Owner: -
--

COMMENT ON COLUMN flights.arrival_airport IS 'Airport of arrival';


--
-- Name: COLUMN flights.status; Type: COMMENT; Schema: dwh; Owner: -
--

COMMENT ON COLUMN flights.status IS 'Flight status';


--
-- Name: COLUMN flights.aircraft_code; Type: COMMENT; Schema: dwh; Owner: -
--

COMMENT ON COLUMN flights.aircraft_code IS 'Aircraft code, IATA';


--
-- Name: COLUMN flights.actual_departure; Type: COMMENT; Schema: dwh; Owner: -
--

COMMENT ON COLUMN flights.actual_departure IS 'Actual departure time';


--
-- Name: COLUMN flights.actual_arrival; Type: COMMENT; Schema: dwh; Owner: -
--

COMMENT ON COLUMN flights.actual_arrival IS 'Actual arrival time';


--
-- Name: flights_flight_id_seq; Type: SEQUENCE; Schema: dwh; Owner: -
--

CREATE SEQUENCE flights_flight_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: flights_flight_id_seq; Type: SEQUENCE OWNED BY; Schema: dwh; Owner: -
--

ALTER SEQUENCE flights_flight_id_seq OWNED BY flights.flight_id;

--
-- Name: flights_flight_id_seq; Type: SEQUENCE; Schema: dwh; Owner: -
--

CREATE TABLE seats (
    aircraft_code character(3) NOT NULL,
    seat_no character varying(4) NOT NULL,
    fare_conditions character varying(10) NOT NULL,
    CONSTRAINT seats_fare_conditions_check CHECK (((fare_conditions)::text = ANY (ARRAY[('Economy'::character varying)::text, ('Comfort'::character varying)::text, ('Business'::character varying)::text])))
);


--
-- Name: TABLE seats; Type: COMMENT; Schema: dwh; Owner: -
--

COMMENT ON TABLE seats IS 'Seats';


--
-- Name: COLUMN seats.aircraft_code; Type: COMMENT; Schema: dwh; Owner: -
--

COMMENT ON COLUMN seats.aircraft_code IS 'Aircraft code, IATA';


--
-- Name: COLUMN seats.seat_no; Type: COMMENT; Schema: dwh; Owner: -
--

COMMENT ON COLUMN seats.seat_no IS 'Seat number';


--
-- Name: COLUMN seats.fare_conditions; Type: COMMENT; Schema: dwh; Owner: -
--

COMMENT ON COLUMN seats.fare_conditions IS 'Travel class';


--
-- Name: ticket_flights; Type: TABLE; Schema: dwh; Owner: -
--

CREATE TABLE ticket_flights (
    ticket_no character(13) NOT NULL,
    flight_id integer NOT NULL,
    fare_conditions character varying(10) NOT NULL,
    amount numeric(10,2) NOT NULL,
    CONSTRAINT ticket_flights_amount_check CHECK ((amount >= (0)::numeric)),
    CONSTRAINT ticket_flights_fare_conditions_check CHECK (((fare_conditions)::text = ANY (ARRAY[('Economy'::character varying)::text, ('Comfort'::character varying)::text, ('Business'::character varying)::text])))
);


--
-- Name: TABLE ticket_flights; Type: COMMENT; Schema: dwh; Owner: -
--

COMMENT ON TABLE ticket_flights IS 'Flight segment';


--
-- Name: COLUMN ticket_flights.ticket_no; Type: COMMENT; Schema: dwh; Owner: -
--

COMMENT ON COLUMN ticket_flights.ticket_no IS 'Ticket number';


--
-- Name: COLUMN ticket_flights.flight_id; Type: COMMENT; Schema: dwh; Owner: -
--

COMMENT ON COLUMN ticket_flights.flight_id IS 'Flight ID';


--
-- Name: COLUMN ticket_flights.fare_conditions; Type: COMMENT; Schema: dwh; Owner: -
--

COMMENT ON COLUMN ticket_flights.fare_conditions IS 'Travel class';


--
-- Name: COLUMN ticket_flights.amount; Type: COMMENT; Schema: dwh; Owner: -
--

COMMENT ON COLUMN ticket_flights.amount IS 'Travel cost';


--
-- Name: tickets; Type: TABLE; Schema: dwh; Owner: -
--

CREATE TABLE tickets (
    ticket_no character(13) NOT NULL,
    book_ref character(6) NOT NULL,
    passenger_id character varying(20) NOT NULL,
    passenger_name text NOT NULL,
    contact_data jsonb
);


--
-- Name: TABLE tickets; Type: COMMENT; Schema: dwh; Owner: -
--

COMMENT ON TABLE tickets IS 'Tickets';


--
-- Name: COLUMN tickets.ticket_no; Type: COMMENT; Schema: dwh; Owner: -
--

COMMENT ON COLUMN tickets.ticket_no IS 'Ticket number';


--
-- Name: COLUMN tickets.book_ref; Type: COMMENT; Schema: dwh; Owner: -
--

COMMENT ON COLUMN tickets.book_ref IS 'Booking number';


--
-- Name: COLUMN tickets.passenger_id; Type: COMMENT; Schema: dwh; Owner: -
--

COMMENT ON COLUMN tickets.passenger_id IS 'Passenger ID';


--
-- Name: COLUMN tickets.passenger_name; Type: COMMENT; Schema: dwh; Owner: -
--

COMMENT ON COLUMN tickets.passenger_name IS 'Passenger name';


--
-- Name: COLUMN tickets.contact_data; Type: COMMENT; Schema: dwh; Owner: -
--

COMMENT ON COLUMN tickets.contact_data IS 'Passenger contact information';


--
-- Name: flights flight_id; Type: DEFAULT; Schema: dwh; Owner: -
--

ALTER TABLE ONLY flights ALTER COLUMN flight_id SET DEFAULT nextval('flights_flight_id_seq'::regclass);

--
-- Name: aircrafts_data aircrafts_pkey; Type: CONSTRAINT; Schema: dwh; Owner: -
--


-- Create the new table with the same structure (metadata) in the bb schema
INSERT INTO dwh.aircrafts_data select * from bookings.aircrafts_data;
INSERT INTO dwh.airports_data select * from bookings.airports_data;
INSERT INTO dwh.boarding_passes select * from bookings.boarding_passes;
INSERT INTO dwh.bookings select * from bookings.bookings;
INSERT INTO dwh.flights select * from bookings.flights;
INSERT INTO dwh.ticket_flights select * from bookings.ticket_flights;
INSERT INTO dwh.tickets select * from bookings.tickets;
INSERT INTO dwh.seats select * from bookings.seats;

--
-- Name: aircrafts_data aircrafts_pkey; Type: CONSTRAINT; Schema: bookings; Owner: -
--

ALTER TABLE ONLY aircrafts_data
    ADD CONSTRAINT aircrafts_pkey PRIMARY KEY (aircraft_code);


--
-- Name: airports_data airports_data_pkey; Type: CONSTRAINT; Schema: dwh; Owner: -
--

ALTER TABLE ONLY airports_data
    ADD CONSTRAINT airports_data_pkey PRIMARY KEY (airport_code);


--
-- Name: boarding_passes boarding_passes_flight_id_boarding_no_key; Type: CONSTRAINT; Schema: dwh; Owner: -
--

ALTER TABLE ONLY boarding_passes
    ADD CONSTRAINT boarding_passes_flight_id_boarding_no_key UNIQUE (flight_id, boarding_no);


--
-- Name: boarding_passes boarding_passes_flight_id_seat_no_key; Type: CONSTRAINT; Schema: dwh; Owner: -
--

ALTER TABLE ONLY boarding_passes
    ADD CONSTRAINT boarding_passes_flight_id_seat_no_key UNIQUE (flight_id, seat_no);


--
-- Name: boarding_passes boarding_passes_pkey; Type: CONSTRAINT; Schema: dwh; Owner: -
--

ALTER TABLE ONLY boarding_passes
    ADD CONSTRAINT boarding_passes_pkey PRIMARY KEY (ticket_no, flight_id);


--
-- Name: bookings bookings_pkey; Type: CONSTRAINT; Schema: dwh; Owner: -
--

ALTER TABLE ONLY bookings
    ADD CONSTRAINT bookings_pkey PRIMARY KEY (book_ref);


--
-- Name: flights flights_flight_no_scheduled_departure_key; Type: CONSTRAINT; Schema: dwh; Owner: -
--

ALTER TABLE ONLY flights
    ADD CONSTRAINT flights_flight_no_scheduled_departure_key UNIQUE (flight_no, scheduled_departure);


--
-- Name: flights flights_pkey; Type: CONSTRAINT; Schema: dwh; Owner: -
--

ALTER TABLE ONLY flights
    ADD CONSTRAINT flights_pkey PRIMARY KEY (flight_id);


--
-- Name: seats seats_pkey; Type: CONSTRAINT; Schema: dwh; Owner: -
--

ALTER TABLE ONLY seats
    ADD CONSTRAINT seats_pkey PRIMARY KEY (aircraft_code, seat_no);


--
-- Name: ticket_flights ticket_flights_pkey; Type: CONSTRAINT; Schema: dwh; Owner: -
--

ALTER TABLE ONLY ticket_flights
    ADD CONSTRAINT ticket_flights_pkey PRIMARY KEY (ticket_no, flight_id);


--
-- Name: tickets tickets_pkey; Type: CONSTRAINT; Schema: dwh; Owner: -
--

ALTER TABLE ONLY tickets
    ADD CONSTRAINT tickets_pkey PRIMARY KEY (ticket_no);


--
-- Name: boarding_passes boarding_passes_ticket_no_fkey; Type: FK CONSTRAINT; Schema: dwh; Owner: -
--

ALTER TABLE ONLY boarding_passes
    ADD CONSTRAINT boarding_passes_ticket_no_fkey FOREIGN KEY (ticket_no, flight_id) REFERENCES ticket_flights(ticket_no, flight_id);


--
-- Name: flights flights_aircraft_code_fkey; Type: FK CONSTRAINT; Schema: dwh; Owner: -
--

ALTER TABLE ONLY flights
    ADD CONSTRAINT flights_aircraft_code_fkey FOREIGN KEY (aircraft_code) REFERENCES aircrafts_data(aircraft_code);


--
-- Name: flights flights_arrival_airport_fkey; Type: FK CONSTRAINT; Schema: dwh; Owner: -
--

ALTER TABLE ONLY flights
    ADD CONSTRAINT flights_arrival_airport_fkey FOREIGN KEY (arrival_airport) REFERENCES airports_data(airport_code);


--
-- Name: flights flights_departure_airport_fkey; Type: FK CONSTRAINT; Schema: dwh; Owner: -
--

ALTER TABLE ONLY flights
    ADD CONSTRAINT flights_departure_airport_fkey FOREIGN KEY (departure_airport) REFERENCES airports_data(airport_code);


--
-- Name: seats seats_aircraft_code_fkey; Type: FK CONSTRAINT; Schema: dwh; Owner: -
--

ALTER TABLE ONLY seats
    ADD CONSTRAINT seats_aircraft_code_fkey FOREIGN KEY (aircraft_code) REFERENCES aircrafts_data(aircraft_code) ON DELETE CASCADE;


--
-- Name: ticket_flights ticket_flights_flight_id_fkey; Type: FK CONSTRAINT; Schema: dwh; Owner: -
--

ALTER TABLE ONLY ticket_flights
    ADD CONSTRAINT ticket_flights_flight_id_fkey FOREIGN KEY (flight_id) REFERENCES flights(flight_id);


--
-- Name: ticket_flights ticket_flights_ticket_no_fkey; Type: FK CONSTRAINT; Schema: dwh; Owner: -
--

ALTER TABLE ONLY ticket_flights
    ADD CONSTRAINT ticket_flights_ticket_no_fkey FOREIGN KEY (ticket_no) REFERENCES tickets(ticket_no);


--
-- Name: tickets tickets_book_ref_fkey; Type: FK CONSTRAINT; Schema: dwh; Owner: -
--

ALTER TABLE ONLY tickets
    ADD CONSTRAINT tickets_book_ref_fkey FOREIGN KEY (book_ref) REFERENCES bookings(book_ref);

--
-- PostgreSQL database dump complete
--

ALTER DATABASE airline SET search_path = dwh, public;
ALTER DATABASE airline SET dwh.lang = en;

