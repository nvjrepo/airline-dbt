with source as (

    select * from {{ source('bookings', 'ticket_flights') }}

),

renamed as (

    select
        {{ dbt_utils.generate_surrogate_key(['ticket_no','flight_id']) }} as ticket_flight_id,
        ticket_no,
        flight_id,
        fare_conditions,
        amount

    from source

)

select * from renamed
