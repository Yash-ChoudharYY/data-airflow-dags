#!/bin/bash

# ==============================================================
# Generate dbt artifacts for Airflow or other orchestration use
# ==============================================================

set -e

# 🧠 Set environment variables for your setup
export SNOWFLAKE_USER=Yash
export SNOWFLAKE_DEVELOPMENT_SCHEMA=YCHOUDHARY
export DBT_PROFILES_DIR=../dbt/profiles/snowflake

# 🧠 Go into your dbt project directory
cd ./dbt

# 🧠 Define where to save artifacts
ARTIFACTS_PATH='../dags/data_team/standard_transformation_scripts/dbt_fan_outs/artifacts'
echo "Generating dbt artifacts in $ARTIFACTS_PATH"

# 🧠 Install or update dbt dependencies
dbt deps

# 🧠 Define selector groups (if you have them defined in selectors.yml)
declare -a Resources=("every_two_hours" "hourly" "twice_daily" "nightly" "weekly" "monthly")

# 🧠 Generate a txt file for each selector — list of models/snapshots
for val in ${Resources[@]}; do
   echo "Persisting DBT list JSON output for selector: $val"
   dbt --log-level error list \
     --selector $val \
     --resource-type model \
     --resource-type snapshot \
     --output json > $ARTIFACTS_PATH/$val.txt &
done

# 🧠 Wait for all parallel background processes to finish
wait

# 🧠 Copy the manifest.json file (complete project metadata)
echo "Persisting DBT manifest.json"
rm -f $ARTIFACTS_PATH/manifest.json
cp target/manifest.json $ARTIFACTS_PATH/manifest.json

echo "✅ Artifact generation complete!"
