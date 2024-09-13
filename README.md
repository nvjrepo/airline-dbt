The DBT project is to store transformation logic for Airline company. Detail is [here](https://postgrespro.com/community/demodb)

## How to use
- Clone this repo to your local
- Ensure you have backend schema `bookings` in the database, by following the steps to install [here](https://postgrespro.com/docs/postgrespro/10/demodb-bookings-installation.html)
- Run scripts in directory analyses/production-backend to clone tables from schema `bookings` to `dwh`, and create cost tables


### Setup profiles:
Navigate to `profiles.yml`, replace below variabe by your credentials:
- POSTGRES_HOST
- DBT_USER
- DBT_PASSWORD
- POSTGRES_PORT
- DBT_DB

Run cli `dbt debug` to ensure dbt is successfully connected to your databases


### Run dbt
Now the project is ready to run. To materialize dbt models into your schema, run below cli:
- dbt run
- dbt test


## Resources:
- Learn more about dbt [in the docs](https://docs.getdbt.com/docs/introduction)
- Check out [Discourse](https://discourse.getdbt.com/) for commonly asked questions and answers
- Join the [chat](https://community.getdbt.com/) on Slack for live discussions and support
- Find [dbt events](https://events.getdbt.com) near you
- Check out [the blog](https://blog.getdbt.com/) for the latest news on dbt's development and best practices


## Convention:
- Always add postfix `_at` after field with `timestamp` style
- For fields with decimal data type, round to 2-4 decimal
- All models, including sources should have at least data tests for uniqueness