with flights as (
    select * from {{ ref('stg_booking__flights') }}
),

seats as (
    select * from {{ ref('stg_booking__seats') }}
),

joined as (
    select
        {{ dbt_utils.generate_surrogate_key(['seats.seat_no','flights.flight_id']) }} as seat_flight_id,
        flights.flight_id,
        flights.actual_departure_at,
        flights.actual_arrival_at,
        seats.seat_no,
        seats.fare_conditions as seat_fare_conditions,
        1 as number_of_seats,
        flights.is_flight_arrived

    from flights
    inner join seats
        on flights.aircraft_code = seats.aircraft_code
)

select * from joined
