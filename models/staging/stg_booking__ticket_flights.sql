with source as (

    select * from {{ source('bookings', 'ticket_flights') }}

),

renamed as (

    select
        {{ dbt_utils.generate_surrogate_key(['ticket_no','flight_id']) }} as ticket_flight_id,
        ticket_no,
        flight_id,
        fare_conditions as fare_conditions_org,
        amount as revenue,

        case when fare_conditions = 'Comfort' then 'Economy' else fare_conditions end as fare_conditions

    from source

)

select * from renamed
