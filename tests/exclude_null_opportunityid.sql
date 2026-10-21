{{ config(severity = 'warn') }}

-- Warns if any opportunity_id in the mart has task counts that include orphan tasks.
-- Since the intermediate model excludes orphans, this should return 0 rows.
select *
from {{ ref('int_opportunity_task_summary') }}
where opportunity_id is null