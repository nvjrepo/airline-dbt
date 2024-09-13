with source as (

    select * from {{ source('bookings', 'boarding_passes') }}

),

renamed as (

    select
        {{ dbt_utils.generate_surrogate_key(['ticket_no','flight_id']) }} as ticket_flight_id,
        ticket_no,
        flight_id,
        boarding_no,
        seat_no

    from source

)

select * from renamed
