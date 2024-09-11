with ticket_flights as (
    select * from {{ ref('stg_booking__ticket_flights') }}
),

tickets as (
    select * from {{ ref('stg_booking__tickets') }}
),

boarding_passes as (
    select * from {{ ref('stg_booking__boarding_passes') }}
),

bookings as (
    select * from {{ ref('stg_booking__bookings') }}
),

joined as (
    select ticket_flights.ticket_flight_id
    from ticket_flights
    left join boarding_passes
        on ticket_flights.ticket_flight_id = boarding_passes.ticket_flight_id
    inner join tickets
        on ticket_flights.ticket_no = tickets.ticket_no
    inner join bookings
        on tickets.book_ref = bookings.book_ref
)

select * from joined
