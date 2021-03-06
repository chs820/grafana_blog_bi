with 

fct_trips as (

    select *
    from {{ ref('fct_trips') }}

),

final as (

    select
        -- date details
        fct_trips.date_stamp
        ,fct_trips.day_name
        ,fct_trips.is_weekday

        ,fct_trips.rider_age

        -- daily trip stats
        ,count(distinct fct_trips.trip_id) as total_trips
        ,count(distinct fct_trips.bike_id) as total_unique_bikes
        ,sum(fct_trips.trip_duration_minutes) as total_trip_duration_minutes
        ,1.0 * sum(fct_trips.trip_duration_minutes) / count(distinct fct_trips.trip_id) as average_trip_duration_minutes

        -- am trip stats
        ,count(distinct case when extract(hour from fct_trips.trip_started_at) < 12 then fct_trips.trip_id end) as am_trips
        ,sum(distinct case when extract(hour from fct_trips.trip_started_at) < 12 then fct_trips.trip_duration_minutes end) as am_trip_duration_minutes
        ,1.0 * sum(distinct case when extract(hour from fct_trips.trip_started_at) < 12 then fct_trips.trip_duration_minutes end) /
            count(distinct case when extract(hour from fct_trips.trip_started_at) < 12 then fct_trips.trip_id end)
            as am_average_trip_duration_minutes

        -- pm trip stats
        ,count(distinct case when extract(hour from fct_trips.trip_started_at) >= 12 then fct_trips.trip_id end) as pm_trips
        ,sum(distinct case when extract(hour from fct_trips.trip_started_at) >= 12 then fct_trips.trip_duration_minutes end) as pm_trip_duration_minutes
        ,1.0 * sum(distinct case when extract(hour from fct_trips.trip_started_at) >= 12 then fct_trips.trip_duration_minutes end) /
            count(distinct case when extract(hour from fct_trips.trip_started_at) >= 12 then fct_trips.trip_id end)
            as pm_average_trip_duration_minutes

    from
        fct_trips
    group by 1,2,3,4

)

select *
from final

