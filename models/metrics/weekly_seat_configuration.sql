with seat_flights as (
    select * from {{ ref('fct_seat_flights') }}
    where is_flight_arrived -- only arrived flights are entitled for calculation relating to loyalty program        
),

ticket_flights as (
    select * from {{ ref('fct_ticket_flights') }}
),

joined as (
    select
        date_trunc('week', seat_flights.actual_arrival_at)::date as calendar_week,

        -- Flights with seats availability
        coalesce(
            count(
                distinct
                case
                    when seat_flights.seat_fare_conditions = 'Economy' then seat_flights.flight_id
                end
            ), 0
        )::bigint as number_of_flights_with_economy_seats_availability,

        coalesce(
            count(
                distinct
                case
                    when seat_flights.seat_fare_conditions = 'Business' then seat_flights.flight_id
                end
            ), 0
        )::bigint as number_of_flights_with_business_seats_availability,

        -- Seats offered
        coalesce(
            sum(
                case
                    when seat_flights.seat_fare_conditions = 'Economy'
                        then seat_flights.number_of_seats * ticket_flights.distance_in_miles
                end
            ), 0
        )::bigint as number_of_economy_seats_miles_offered_on_flights,

        coalesce(
            sum(
                case
                    when seat_flights.seat_fare_conditions = 'Business'
                        then seat_flights.number_of_seats * ticket_flights.distance_in_miles
                end
            ), 0
        )::bigint as number_of_business_seats_miles_offered_on_flights,

        -- Seats Taken
        coalesce(
            sum(
                case
                    when ticket_flights.fare_conditions = 'Economy'
                        then seat_flights.number_of_seats * ticket_flights.distance_in_miles
                end
            ), 0
        )::bigint as number_of_economy_seats_miles_taken,

        coalesce(
            sum(
                case
                    when ticket_flights.fare_conditions = 'Business'
                        then seat_flights.number_of_seats * ticket_flights.distance_in_miles
                end
            ), 0
        )::bigint as number_of_business_seats_miles_taken,


        -- Revenue & Cost
        --- Economy
        coalesce(
            sum(
                case
                    when
                        ticket_flights.fare_conditions = 'Economy' then ticket_flights.flight_revenue
                end
            ), 0
        )::bigint
        / nullif(
            sum(
                case
                    when ticket_flights.fare_conditions = 'Economy'
                        then seat_flights.number_of_seats * ticket_flights.distance_in_miles
                end
            ), 0
        )::bigint as revenue_per_economy_seat_mile,

        coalesce(
            sum(
                case
                    when
                        ticket_flights.fare_conditions = 'Economy'
                        then ticket_flights.passenger_meal_cost
                            + ticket_flights.flight_cleaning_cost
                            + ticket_flights.flight_fuel_cost
                end
            ), 0
        )::bigint
        / nullif(
            sum(
                case
                    when ticket_flights.fare_conditions = 'Economy'
                        then seat_flights.number_of_seats * ticket_flights.distance_in_miles
                end
            ), 0
        )::bigint as cost_per_economy_seat_mile,

        --- Business
        coalesce(
            sum(
                case
                    when
                        ticket_flights.fare_conditions = 'Business' then ticket_flights.flight_revenue
                end
            ), 0
        )::bigint
        / nullif(
            sum(
                case
                    when ticket_flights.fare_conditions = 'Business'
                        then seat_flights.number_of_seats * ticket_flights.distance_in_miles
                end
            ), 0
        )::bigint as revenue_per_business_seat_mile,

        coalesce(
            sum(
                case
                    when
                        ticket_flights.fare_conditions = 'Business'
                        then ticket_flights.passenger_meal_cost
                            + ticket_flights.flight_cleaning_cost
                            + ticket_flights.flight_fuel_cost
                end
            ), 0
        )::bigint
        / nullif(
            sum(
                case
                    when ticket_flights.fare_conditions = 'Business'
                        then seat_flights.number_of_seats * ticket_flights.distance_in_miles
                end
            ), 0
        )::bigint as cost_per_business_seat_mile

    from seat_flights
    left join ticket_flights
        on seat_flights.seat_flight_id = ticket_flights.seat_flight_id
            and ticket_flights.seat_no is not null
    group by 1
)

select * from joined
