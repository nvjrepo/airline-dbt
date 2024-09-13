with source as (

    select * from {{ source('bookings', 'ticket_flights') }}

),

renamed as (

    select
        {{ dbt_utils.generate_surrogate_key(['ticket_no','flight_id']) }} as ticket_flight_id,
        ticket_no,
        flight_id,
        fare_conditions as fare_conditions_org,
        cast(amount as bigint) as revenue,

        (
            case when fare_conditions = 'Comfort' then 'Economy' else fare_conditions end
        )::text as fare_conditions,
        round((1.0 / count(*) over (partition by flight_id))::numeric, 4) as flight_divider

    from source

)

select * from renamed
