with flights as (
    select * from {{ ref('stg_booking__flights') }}
),

seats as (
    select * from {{ ref('stg_booking__seats') }}
),

boarding_passes as (
    select * from {{ ref('stg_booking__boarding_passes') }}
),

-- get all seats for flights
joined as (
    select
        {{ dbt_utils.generate_surrogate_key(['seats.seat_no','flights.flight_id']) }} as seat_flight_id,
        flights.flight_id,
        flights.actual_departure_at,
        flights.actual_arrival_at,
        flights.is_flight_arrived,
        seats.seat_no,
        seats.fare_conditions as seat_fare_conditions,
        1 as number_of_seats,
        boarding_passes.seat_no is not null as is_seat_taken

    from flights
    inner join seats
        on flights.aircraft_code = seats.aircraft_code
    left join boarding_passes
        on flights.flight_id = boarding_passes.flight_id
            and seats.seat_no = boarding_passes.seat_no
)

select * from joined
