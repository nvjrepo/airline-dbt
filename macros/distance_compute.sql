
{% macro travel_distance(unit, departure_point, arrival_point) %}
    st_distance(
        -- convert native point to geography
        st_setsrid(st_makepoint({{ departure_point }}[0], {{ departure_point }}[1]), 4326)::geography,
        st_setsrid(st_makepoint({{ arrival_point }}[0], {{ arrival_point }}[1]), 4326)::geography
    ) / 
    {%- if unit == 'miles' -%} 
        1609.34
    {%- elif unit == 'km' -%} 
        1000
    {%- else -%}
        1 -- default type is meter
    {%- endif -%}
{% endmacro %}