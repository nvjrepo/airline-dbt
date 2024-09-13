with source as (

    select * from {{ source('google_sheets', 'cost_mapping_short_term') }}

),

renamed as (

    select
        "month" as cost_month,
        cost_type,
        rate,
        unit,
        fare_condition,
        aircraft_code

    from source

)

select * from renamed
