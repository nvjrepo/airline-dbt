{{
    config(
        materialized = 'table'
    )
}}

with flights as (
    select * from {{ ref('stg_booking__flights') }}
),

airports as (
    select * from {{ ref('stg_booking__airports') }}
),

seats as (
    select
        aircraft_code,
        count(distinct seat_no) as number_of_seats

    from {{ ref('stg_booking__seats') }}
    {{ dbt_utils.group_by(1) }}
)

select
    flights.flight_id,
    flights.aircraft_code,
    flights.scheduled_departure_at,
    flights.scheduled_arrival_at,
    flights.actual_departure_at,
    flights.actual_arrival_at,
    flights.is_flight_arrived,
    dep_airports.airport_name as departure_airport,
    arr_airports.airport_name as arrival_airport,
    seats.number_of_seats,

    ({{ travel_distance(
            unit = 'miles',
            departure_point = 'dep_airports.coordinates',
            arrival_point = 'arr_airports.coordinates'
        ) }})::bigint as distance_in_km,

    ({{ travel_distance(
            unit = 'miles',
            departure_point = 'dep_airports.coordinates',
            arrival_point = 'arr_airports.coordinates'
        ) }})::bigint as distance_in_miles

from flights
inner join airports as dep_airports
    on flights.departure_airport_code = dep_airports.airport_code
inner join airports as arr_airports
    on flights.arrival_airport_code = arr_airports.airport_code
inner join seats
    on flights.aircraft_code = seats.aircraft_code
