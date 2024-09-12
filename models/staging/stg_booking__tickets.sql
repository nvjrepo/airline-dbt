with source as (

    select * from {{ source('bookings', 'tickets') }}

),

renamed as (

    select
        ticket_no,
        book_ref,
        passenger_id,
        passenger_name,
        contact_data,

        row_number() over (partition by book_ref order by ticket_no) = 1 as is_lead_booking_passenger

    from source

)

select * from renamed
