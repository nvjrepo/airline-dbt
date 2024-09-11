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
),

joined as (
    select flights.flight_id

    from flights
    inner join airports as dep_airports
        on flights.departure_airport = dep_airports.airport_code
    inner join airports as arr_airports
        on flights.arrival_airport = arr_airports.airport_code
    inner join seats
        on flights.aircraft_code = seats.aircraft_code
)

select * from joined
