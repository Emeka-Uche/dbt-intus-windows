with stage_events as (
    select * from {{ ref('stg_crm_opportunity_stage_history') }}
),

wf as (
    select
        opportunity_id,
        stage_name,
        changed_at,
        row_number() over (
            partition by opportunity_id
            order by changed_at desc, stage_event_id desc
        ) as rn
    from stage_events
)

select
    opportunity_id,
    stage_name   as latest_stage,
    changed_at   as latest_stage_changed_at
from wf
where rn = 1