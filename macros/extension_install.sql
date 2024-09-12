{% macro create_extensions() %}
    create extension if not exists postgis

{% endmacro %}