with tasks as (
    select * from {{ ref('stg_crm_tasks') }}
    where opportunity_id is not null
),

reporting as (
    select '{{ var("reporting_date") }}'::date as reporting_date
),


task_rollup as (
    select
        t.opportunity_id,

        count_if(t.task_status != 'Completed') as open_task_count,

        count_if(
            t.task_status != 'Completed'
            and t.due_date is not null
            and t.due_date < r.reporting_date
        ) as overdue_task_count,

        max(t.created_at) as latest_task_created_at,

        max(case when t.completed_at is not null then t.completed_at end) as latest_completed_at,

        count_if(t.completed_at is not null) as completed_task_count,

        max(
            case
                when t.completed_at is not null then t.completed_at
                else t.created_at
            end
        ) as latest_task_activity_at

    from tasks t
    cross join reporting r
    group by t.opportunity_id
)

select * from task_rollup