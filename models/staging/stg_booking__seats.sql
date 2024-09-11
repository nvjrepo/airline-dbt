with source as (

    select * from {{ source('bookings', 'seats') }}

),

renamed as (

    select
        {{ dbt_utils.generate_surrogate_key(['seat_no','aircraft_code']) }} as seat_aircraft_id,
        aircraft_code,
        seat_no,
        fare_conditions

    from source

)

select * from renamed
