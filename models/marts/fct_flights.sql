with flights as (
    select * from {{ ref('stg_booking__flights') }}
),

airports as (
    select * from {{ ref('stg_booking__airports') }}
),

seats as (
    select
        aircraft_code,
        count(distinct seat_no) as number_of_seats

    from {{ ref('stg_booking__seats') }}
    {{ dbt_utils.group_by(1) }}
),

joined as (
    select
        flights.flight_id,
        flights.scheduled_departure_at,
        flights.scheduled_arrival_at,
        flights.actual_departure_at,
        flights.actual_arrival_at,
        dep_airports.airport_name as departure_airport,
        arr_airports.airport_name as arrival_airport,
        seats.number_of_seats,
        seats.number_of_seats * {{ var('cleaning_cost_per_seat') }} as flight_cleaning_cost,

        -- Fuel cost is only applied for depart and arrived flights
        case
            when flights.is_flight_arrived
                then ({{ travel_distance(
                        unit = 'km',
                        departure_point = 'dep_airports.coordinates',
                        arrival_point = 'arr_airports.coordinates'
                    ) }}) * {{ var('fuel_cost_per_km') }}
        end as flight_fuel_cost,

        {{ travel_distance(
            unit = 'miles',
            departure_point = 'dep_airports.coordinates',
            arrival_point = 'arr_airports.coordinates'
        ) }} as distance_in_miles

    from flights
    inner join airports as dep_airports
        on flights.departure_airport_code = dep_airports.airport_code
    inner join airports as arr_airports
        on flights.arrival_airport_code = arr_airports.airport_code
    inner join seats
        on flights.aircraft_code = seats.aircraft_code
)

select * from joined
