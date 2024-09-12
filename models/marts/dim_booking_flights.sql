with flights as (
    select * from {{ ref('int_ticket_flights__joined') }}
    where is_lead_booking_passenger
),

final as (
    select
        book_flight_id,
        flight_id,
        book_ref,
        passenger_id as lead_passenger_id,
        passenger_name as lead_passenger_name,
        fare_conditions as lead_fare_condition

    from flights
)

select * from final
