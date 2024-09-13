with ticket_flights as (
    select * from {{ ref('int_ticket_flights__joined') }}
),

boarding_passes as (
    select * from {{ ref('stg_booking__boarding_passes') }}
),

flights as (
    select * from {{ ref('int_flights__joined') }}
),

joined as (
    select
        -- id and key
        ticket_flights.ticket_flight_id,
        ticket_flights.book_flight_id,
        ticket_flights.ticket_no,
        ticket_flights.flight_id,
        ticket_flights.passenger_id,
        {{ dbt_utils.generate_surrogate_key(
            ['boarding_passes.seat_no', 'ticket_flights.flight_id']
        ) }} as seat_flight_id,

        -- timestamp
        flights.actual_departure_at,
        flights.actual_arrival_at,

        -- flight information        
        ticket_flights.passenger_name,
        ticket_flights.fare_conditions,
        flights.departure_airport,
        flights.arrival_airport,
        boarding_passes.seat_no,

        -- boolean for downstream filters
        flights.is_flight_arrived,
        ticket_flights.is_lead_booking_passenger,
        boarding_passes.ticket_flight_id is not null as is_boarding_passes_printed,

        -- numeric metrics
        flights.number_of_seats,
        flights.distance_in_miles,
        ticket_flights.revenue as flight_revenue,
        (flights.number_of_seats
        * ticket_flights.flight_divider
        * {{ var('cleaning_cost_per_seat') }})::bigint as flight_cleaning_cost,

        (case
            when flights.is_flight_arrived
                then flights.distance_in_km * ticket_flights.flight_divider * {{ var('fuel_cost_per_km') }}
        end)::bigint as flight_fuel_cost,

        (case
            when ticket_flights.fare_conditions = 'Economy' then {{ var('meal_cost_economy') }}
            else {{ var('meal_cost_business') }}
        end)::bigint as passenger_meal_cost

    from ticket_flights
    left join boarding_passes
        on ticket_flights.ticket_flight_id = boarding_passes.ticket_flight_id
    inner join flights
        on ticket_flights.flight_id = flights.flight_id

)

select * from joined
