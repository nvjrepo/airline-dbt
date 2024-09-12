with ticket_flights as (
    select * from {{ ref('fct_ticket_flights') }}
),

booking_flights as (
    select * from {{ ref('dim_booking_flights') }}
),

flights as (
    select * from {{ ref('fct_flights') }}
    where is_flight_arrived -- only arrived flights are entitled for calculation relating to loyalty program
),

joined as (
    select
        date_trunc('month', date(flights.actual_arrival_at)) as calendar_month,
        booking_flights.lead_passenger_id,

        -- Flights and Miles
        --- Economy
        count(
            distinct case
                when
                    ticket_flights.is_lead_booking_passenger and booking_flights.lead_fare_conditions = 'Economy'
                    then ticket_flights.flight_id
            end
        ) as number_of_economy_flights_taken,

        coalesce(
            sum(
                case
                    when
                        ticket_flights.is_lead_booking_passenger and booking_flights.lead_fare_conditions = 'Economy'
                        then flights.distance_in_miles
                end
            ), 0
        ) as number_of_economy_miles_flown,

        --- Business
        count(
            distinct case
                when
                    ticket_flights.is_lead_booking_passenger and booking_flights.lead_fare_conditions = 'Business'
                    then ticket_flights.flight_id
            end
        ) as number_of_business_flights_taken,

        coalesce(
            sum(
                case
                    when
                        ticket_flights.is_lead_booking_passenger and booking_flights.lead_fare_conditions = 'Business'
                        then flights.distance_in_miles
                end
            ), 0
        ) as number_of_business_miles_flown,

        --- Total
        count(
            distinct case
                when ticket_flights.is_lead_booking_passenger then ticket_flights.flight_id
            end
        ) as total_flights_taken,

        coalesce(
            sum(
                case
                    when
                        ticket_flights.is_lead_booking_passenger then flights.distance_in_miles
                end
            ), 0
        ) as total_miles_flown,

        round(
            (count(
                distinct case
                    when
                        ticket_flights.is_lead_booking_passenger and booking_flights.lead_fare_conditions = 'Economy'
                        then ticket_flights.flight_id
                end
            )
            / count(
                distinct case
                    when ticket_flights.is_lead_booking_passenger then ticket_flights.flight_id
                end
            ))::numeric, 2
        ) as p_of_economy_flights_taken,

        round(
            (coalesce(
                sum(
                    case
                        when
                            ticket_flights.is_lead_booking_passenger
                            and booking_flights.lead_fare_conditions = 'Economy'
                            then flights.distance_in_miles
                    end
                ), 0
            )
            / sum(
                case
                    when
                        ticket_flights.is_lead_booking_passenger then flights.distance_in_miles
                end
            ))::numeric, 2
        ) as p_of_economy_miles_flown,

        -- Revenue, Cost and Gross Margin
        --- Economy
        coalesce(
            sum(
                case
                    when
                        booking_flights.lead_fare_conditions = 'Economy' then ticket_flights.revenue
                end
            ), 0
        )::bigint as revenue_from_economy_flights,

        coalesce(
            sum(
                case
                    when
                        booking_flights.lead_fare_conditions = 'Economy'
                        then ticket_flights.passenger_meal_cost
                            + flights.flight_cleaning_cost * ticket_flights.flight_divider
                            + flights.flight_fuel_cost * ticket_flights.flight_divider
                end
            ), 0
        )::bigint as cost_from_economy_flights,

        coalesce(
            sum(
                case
                    when
                        booking_flights.lead_fare_conditions = 'Economy' then ticket_flights.revenue
                end
            ), 0
        )::bigint
        - coalesce(
            sum(
                case
                    when
                        booking_flights.lead_fare_conditions = 'Economy'
                        then ticket_flights.passenger_meal_cost
                            + flights.flight_cleaning_cost * ticket_flights.flight_divider
                            + flights.flight_fuel_cost * ticket_flights.flight_divider
                end
            ), 0
        )::bigint as profit_margin_from_economy_flights,

        --- Business
        coalesce(
            sum(
                case
                    when
                        booking_flights.lead_fare_conditions = 'Business' then ticket_flights.revenue
                end
            ), 0
        )::bigint as revenue_from_business_flights,

        coalesce(
            sum(
                case
                    when
                        booking_flights.lead_fare_conditions = 'Business'
                        then ticket_flights.passenger_meal_cost
                            + flights.flight_cleaning_cost * ticket_flights.flight_divider
                            + flights.flight_fuel_cost * ticket_flights.flight_divider
                end
            ), 0
        )::bigint as cost_from_business_flights,

        coalesce(
            sum(
                case
                    when
                        booking_flights.lead_fare_conditions = 'Business' then ticket_flights.revenue
                end
            ), 0
        )::bigint
        - coalesce(
            sum(
                case
                    when
                        booking_flights.lead_fare_conditions = 'Business'
                        then ticket_flights.passenger_meal_cost
                            + flights.flight_cleaning_cost * ticket_flights.flight_divider
                            + flights.flight_fuel_cost * ticket_flights.flight_divider
                end
            ), 0
        )::bigint as profit_margin_from_business_flights

    from ticket_flights
    inner join booking_flights
        on ticket_flights.book_flight_id = booking_flights.book_flight_id
    inner join flights
        on ticket_flights.flight_id = flights.flight_id
    {{ dbt_utils.group_by(2) }}
)

select * from joined
