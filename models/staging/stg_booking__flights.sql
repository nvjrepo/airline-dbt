with source as (

    select * from {{ source('bookings', 'flights') }}

),

renamed as (

    select
        flight_id,
        flight_no,

        actual_departure as actual_departure_at,
        actual_arrival as actual_arrival_at,
        scheduled_departure as scheduled_departure_at,
        scheduled_arrival as scheduled_arrival_at,

        departure_airport as departure_airport_code,
        arrival_airport as arrival_airport_code,
        status,
        aircraft_code,

        status = 'Arrived' as is_flight_arrived

    from source

)

select * from renamed
