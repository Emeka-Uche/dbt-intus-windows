select
    trim(task_id)                                   as task_id,
    nullif(trim(opportunity_id), '')                as opportunity_id,
    trim(task_status)                               as task_status,
    try_to_timestamp(created_at::varchar)           as created_at,
    try_to_date(nullif(trim(due_date::varchar), ''))          as due_date,
    try_to_timestamp(nullif(trim(completed_at::varchar), '')) as completed_at
from {{ source('sales_pipeline', 'src_crm_tasks') }}