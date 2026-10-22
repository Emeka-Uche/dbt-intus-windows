# Sales Pipeline Health Dashboard

A dbt and Snowflake analytics project designed to help Sales Operations identify stale opportunities, prioritise follow-ups, and monitor pipeline performance.

## Tech Stack
- **Snowflake:** Data warehouse
- **dbt:** Data transformation, modelling, and testing
- **SQL:** Business logic and data validation
- **Zoho Analytics:** Dashboard and visualisation

## Data Model

The project follows a layered dbt architecture:

- **Staging:** Cleans and standardises source data.
- **Intermediate:** Identifies the latest opportunity stages and summarises task activity.
- **Mart:** Combines the data into `fct_sales_pipeline_health`, with one row per opportunity.
- **Semantic Layer:** Defines reusable metrics for consistent reporting.

## Key Features

- Identifies stale opportunities and required follow-ups.
- Monitors pipeline value and opportunity stages.
- Flags missing owners, unknown stages, and incomplete data.
- Applies consistent business rules and automated data quality tests.

## Validation

The project was validated using `dbt build`, `dbt parse`, and dbt Semantic Layer metric validation.

## Running the Project

1. Load the source data into Snowflake.
<<<<<<< HEAD
2. Configure your dbt connection. - 
    
    ```bash
    source .env
    dbt debug
    ```
3. To view documentation, run:

   ```bash
    dbt docs serve
   ```
4. Run:
   ```bash
   dbt parse
   dbt build
   ```
## Business Value

The solution turns CRM data into actionable sales insights, helping teams identify at-risk opportunities and focus follow-up efforts where they matter most.

*Developed as a data analytics case study for INTUS Windows.*
