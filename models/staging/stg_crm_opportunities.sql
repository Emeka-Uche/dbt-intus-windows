select
    trim(opportunity_id)    as opportunity_id,
    trim(opportunity_name)  as opportunity_name,
    nullif(trim(owner_id), '') as owner_id,
    try_to_number(nullif(trim(amount::varchar), '')) as opportunity_amount,
    try_to_timestamp(created_at::varchar)            as created_at,
    coalesce(try_to_boolean(is_test_record::varchar), false) as is_test_record
from {{ source('sales_pipeline', 'src_crm_opportunities') }}