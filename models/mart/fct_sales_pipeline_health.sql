with opportunities as (
    select * from {{ ref('stg_crm_opportunities') }}
),

people as (
    select * from {{ ref('stg_sales_people') }}
),

latest_stage as (
    select * from {{ ref('int_opportunity_latest_stage') }}
),

task_summary as (
    select * from {{ ref('int_opportunity_task_summary') }}
),

reporting as (
    select '{{ var("reporting_date") }}'::date as reporting_date
),

combined as (
    select
        o.opportunity_id,
        o.opportunity_name,
        o.owner_id,
        o.opportunity_amount,
        o.created_at::date as created_at,
        o.is_test_record,

        p.employee_name  as owner_name,
        p.owner_role           as owner_role,
        coalesce(p.is_owner_active, false) as owner_is_active,
        p.team_lead,

        ls.latest_stage,
        case
            when ls.latest_stage in ('New', 'Qualified', 'Proposal', 'Negotiation') then 'active'
            when ls.latest_stage = 'On Hold'      then 'on_hold'
            when ls.latest_stage = 'Closed Won'   then 'won'
            when ls.latest_stage = 'Closed Lost'  then 'lost'
            else 'unknown'
        end as pipeline_category,

        ls.latest_stage_changed_at,
        datediff(
            'day',
            ls.latest_stage_changed_at::date,
            r.reporting_date
        ) as days_in_current_stage,

        coalesce(ts.open_task_count, 0)     as open_task_count,
        coalesce(ts.overdue_task_count, 0)  as overdue_task_count,
        ts.latest_task_activity_at,
        datediff(
            'day',
            ts.latest_task_activity_at::date,
            r.reporting_date
        ) as days_since_last_task_activity,

        -- Eligibility: not test, owner exists and active, role in (Rep, Manager), category active
        coalesce(
            not o.is_test_record
            and p.is_owner_active = true
            and p.owner_role in ('Sales Representative', 'Sales Manager')
            and (
                ls.latest_stage in ('New', 'Qualified', 'Proposal', 'Negotiation')
            ),
            false
        ) as is_eligible_active,

        r.reporting_date

    from opportunities o
    left join people       p  on o.owner_id = p.employee_id
    left join latest_stage ls on o.opportunity_id = ls.opportunity_id
    left join task_summary ts on o.opportunity_id = ts.opportunity_id
    cross join reporting r
),

flags as (
    select
        combined.*,
        --ts.open_task_count,
        --overdue_task_count,
        ts.latest_task_created_at,
        ts.latest_completed_at,
        ts.completed_task_count,
        --ts.latest_task_activity_at,

        -- Defining Stale: eligible AND latest stage change > 14 days before reporting date
        coalesce(
            is_eligible_active
            and days_in_current_stage > 14,
            false
        ) as is_stale,

        -- Defining Recent follow-up: completed task in last 14 days.
        coalesce(
            case
                when coalesce(ts.completed_task_count, 0) > 0 then
                    datediff('day', ts.latest_completed_at::date, reporting_date) <= 14
                else
                    datediff('day', ts.latest_task_created_at::date, reporting_date) <= 14
            end,
            false
        ) as has_recent_followup

    from combined
    left join task_summary ts on combined.opportunity_id = ts.opportunity_id
),

final as (
    select
        *,

        -- Requires follow-up: eligible AND (stale OR overdue task OR no recent follow-up)
        coalesce(
            is_eligible_active
            and (
                is_stale
                or overdue_task_count > 0
                or not has_recent_followup
            ),
            false
        ) as requires_follow_up,

        nullif(
            array_to_string(
                array_construct_compact(
                    case when is_stale then 'Stale >14 days' end,
                    case when overdue_task_count > 0 then 'Overdue task' end,
                    case when not has_recent_followup then 'No recent follow-up' end
                ),
                '; '
            ),
            ''
        ) as follow_up_reason

    from flags
)

select
    opportunity_id,
    opportunity_name,
    owner_name,
    owner_role,
    owner_is_active,
    team_lead,
    latest_stage,
    pipeline_category,
    opportunity_amount,
    created_at,
    latest_stage_changed_at,
    days_in_current_stage,
    is_eligible_active,
    is_stale,
    open_task_count,
    overdue_task_count,
    latest_task_activity_at,
    days_since_last_task_activity,
    has_recent_followup,
    requires_follow_up,
    follow_up_reason,
    reporting_date
from final
