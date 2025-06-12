# Unified Mobility Centre (UMC)

This repository provides a starting point for modelling a Unified Mobility Centre backend for Malaysia. The goal is to integrate multimodal transport data such as public transport networks, real-time road congestion, park-and-ride facilities and subsidy eligibility.

The project currently contains sample SQL queries demonstrating how analytics could be run on a theoretical UMC database schema. These examples include:

- Simulating multimodal journeys (MRT + feeder bus + walking)
- Checking subsidy eligibility based on a user's MyKad
- Identifying underutilised MRT stations
- Retrieving the most congested routes
- Finding nearby park-and-ride stations
- Calculating average journey duration by income group
- Linking congestion data with journey logs
- Creating SQL views for dashboards

The `sql/umc_queries.sql` file consolidates these sample queries for easy reference.

## Repository structure

```
LICENSE          - Project licensing information (MIT)
README.md        - This overview
sql/             - Directory containing example SQL queries
```

Feel free to extend the project with additional data definitions, queries or documentation.
