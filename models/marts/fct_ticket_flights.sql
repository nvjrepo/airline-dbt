with ticket_flights as (
    select * from {{ ref('int_ticket_flights__joined') }}
),

boarding_passes as (
    select * from {{ ref('stg_booking__boarding_passes') }}
),

joined as (
    select
        ticket_flights.ticket_flight_id,
        ticket_flights.book_flight_id,
        ticket_flights.flight_id,
        ticket_flights.ticket_no,
        ticket_flights.revenue,
        ticket_flights.passenger_id,
        ticket_flights.passenger_name,
        ticket_flights.fare_conditions,
        ticket_flights.is_lead_booking_passenger,

        boarding_passes.seat_no,
        boarding_passes.ticket_flight_id is not null as is_boarding_passes_print,

        case
            when ticket_flights.fare_conditions = 'Economy' then {{ var('meal_cost_economy') }}
            else {{ var('meal_cost_business') }}
        end as passenger_meal_cost,

        round((1.0 / count(*) over (partition by ticket_flights.flight_id))::numeric, 4) as flight_divider

    from ticket_flights
    left join boarding_passes
        on ticket_flights.ticket_flight_id = boarding_passes.ticket_flight_id
)

select * from joined
