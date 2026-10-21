{{
    config(materialized = 'table')
}}

with generator as (
    select
        row_number() over (order by seq4()) - 1 as seq
    from table(generator(rowcount => 20000))
),

dates as (
    select
        dateadd(day, seq, '2020-01-01'::date) as date_day
    from generator
)

select date_day
from dates
where date_day <= '2030-12-31'::date