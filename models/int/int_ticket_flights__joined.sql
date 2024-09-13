with ticket_flights as (
    select * from {{ ref('stg_booking__ticket_flights') }}
),

tickets as (
    select * from {{ ref('stg_booking__tickets') }}
)

select
    ticket_flights.ticket_flight_id,
    ticket_flights.flight_id,
    ticket_flights.fare_conditions,
    ticket_flights.ticket_no,
    ticket_flights.revenue,
    ticket_flights.flight_divider,
    tickets.book_ref,
    tickets.passenger_id,
    tickets.passenger_name,
    tickets.is_lead_booking_passenger,

    {{ dbt_utils.generate_surrogate_key(['tickets.book_ref','ticket_flights.flight_id']) }} as book_flight_id

from ticket_flights
inner join tickets
    on ticket_flights.ticket_no = tickets.ticket_no
