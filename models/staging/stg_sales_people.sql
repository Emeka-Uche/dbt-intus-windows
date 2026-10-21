select
    trim(employee_id)    as employee_id,
    trim(employee_name)  as employee_name,
    trim(role)           as owner_role,
    trim(team_lead)      as team_lead,
    try_to_boolean(is_active::varchar) as is_owner_active
from {{ source('sales_pipeline', 'src_sales_people') }}