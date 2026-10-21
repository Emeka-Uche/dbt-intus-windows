-- This test fails if any row has requires_follow_up = true but none of the three reasons is true,
-- or requires_follow_up = false but at least one reason is true while eligible.
select *
from {{ ref('fct_sales_pipeline_health') }}
where is_eligible_active = true
  and (
      (requires_follow_up = true
       and is_stale = false
       and overdue_task_count = 0
       and has_recent_followup = true)
      or
      (requires_follow_up = false
       and (is_stale = true or overdue_task_count > 0 or has_recent_followup = false))
  )