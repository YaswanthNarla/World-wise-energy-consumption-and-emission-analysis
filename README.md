World Wide Energy Consumption & Emission Analysis
📌 Overview
This project analyzes global energy data using SQL.
You study how energy production, consumption, emissions, GDP, and population interact across countries and years.
The goal:
Turn raw data into insights for economic performance, energy usage, and environmental impact.
🎯 Objectives
Analyze relationship between energy, economy, and emissions
Identify top economies and energy patterns
Evaluate energy balance (production vs consumption)
Track year-over-year trends
Perform per capita analysis
Build efficiency metrics (emission-to-GDP, energy intensity)
🗂️ Dataset Structure
You work with 6 tables:
country → master table
emission_3 → emissions + per capita emissions
population → population data
production → energy production
consumption → energy consumption
gdp_3 → GDP values
👉 Schema and queries:
🔗 Data Model
One country → many records in all tables
Common keys:
country
year
This enables:
time-based analysis
cross-table joins
per capita calculations
📊 Key Analysis Areas
1. General Analysis
Total emissions by country
Top GDP countries
Energy balance (production vs consumption)
Emission by energy type
2. Trend Analysis
Global emissions growth
GDP trends
Population vs emissions
Energy consumption trends
3. Ratio & Per Capita Analysis
Emission-to-GDP ratio
Energy consumption per capita
Production per capita
Energy intensity
4. Global Comparison
Top population vs emissions
Emission reduction trends
Global emission share
Global averages
⚙️ Key Metrics Used
Emission Intensity
Emission / GDP
Energy per Capita
Consumption / Population
Energy Balance
Production - Consumption
Growth (YoY)
Current - Previous (using LAG)
📈 Key Insights
Emissions
Coal and petroleum dominate emissions
Few countries contribute majority share
Global emissions show upward trend
Energy
Many countries depend on energy imports
Resource-rich countries produce surplus
Renewables show steady growth
Economy
GDP growth linked with energy usage
High GDP → high energy demand
Efficiency varies across countries
Population
Population growth drives energy demand
Per capita metrics reveal inequality

🚧 Challenges
Handling joins across multiple tables
Managing duplicates and aggregation
Writing window functions (LAG)
Ensuring correct units and calculations

🛠️ Tools Used
SQL (MySQL)
Relational Data Modeling
Window Functions
Aggregations & Joins

📂 Project Files
SQL scripts → queries and schema
Dataset → CSV files
Presentation → insights summary

✅ Conclusion
Energy, economy, and emissions are tightly linked.
A small number of countries dominate global impact.
Future direction:
Improve energy efficiency
Shift to renewable sources
Balance growth with sustainability
⭐ What you learn from this project
Real-world SQL problem solving
Data modeling and joins
Business-driven analysis
Building insights from raw data
