select
    stage_event_id::integer          as stage_event_id,
    trim(opportunity_id)             as opportunity_id,
    trim(stage_name)                 as stage_name,
    try_to_timestamp(changed_at::varchar) as changed_at
from {{ source('sales_pipeline', 'src_opportunity_stage_history') }}