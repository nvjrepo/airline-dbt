{{
    config(
        enabled=false
    )
}}

-- were boarding passes printed for all tickets? => no
select count(*)
from ticket_flights
left join boarding_passes bp 
    on ticket_flights.ticket_no = bp.ticket_no 
        and ticket_flights.flight_id = bp.flight_id
where bp.ticket_no is null

-- fare condition are similar between `seats` tables and `ticket_flights` table? => yes
select count(*)
from ticket_flights
left join boarding_passes bp 
    on ticket_flights.ticket_no = bp.ticket_no 
        and ticket_flights.flight_id = bp.flight_id
left join flights 
    on flights.flight_id = bp.flight_id
left join seats s 
    on bp.seat_no = s.seat_no 
        and flights.aircraft_code = s.aircraft_code
where bp.ticket_no is not null
    and (case when ticket_flights.fare_conditions = 'Comfort' then 'Economy' else ticket_flights.fare_conditions end) != (case when s.fare_conditions = 'Comfort' then 'Economy' else s.fare_conditions end)
