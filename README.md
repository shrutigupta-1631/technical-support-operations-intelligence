# Technical Support Operations Intelligence

An end-to-end data analytics project analyzing **2,330 technical support tickets** from **12 countries** during **January–December 2023** using **Excel**, **Power Query**, **SQL**, and **Power BI**.

## Project Objective

Analyze support demand, service performance, SLA compliance, customer satisfaction, and agent efficiency to identify actionable opportunities for improving support operations.

## Tools Used
- **Excel** — Data cleaning, validation, audit, and data dictionary
- **SQL (MySQL)** — Data loading, transformation, star schema design, and business analysis
- **Power BI** — Data modeling, DAX measures, interactive dashboard, and visualization

## Project Workflow

**Raw Data** → **Excel Cleaning & Validation** → **SQL Star Schema** → **SQL Analysis** → **Power BI Dashboard** → **Business Insights**

## Data Quality: Audit & Dictionary

Before any modeling, every column was validated and documented in Excel:

- **Data Audit** —  Raw dataset containing 2,351 records was cleaned by removing duplicates, standardizing text values, validating timestamps, enriching agent information, and creating business-ready derived columns. The final dataset contains 2,330 records and ready for SQL data modeling and Power BI analysis.		

- **Data Dictionary** — every field defined with its data type, allowed values, and business meaning, so the star schema and DAX measures downstream trace back to a documented definition.

Both live as sheets inside the cleaned workbook (`01_Data/2_Technical Support - Clean Data.xlsx`) — summarized here so they're visible without opening Excel:

### Data Audit
| **Data Quality Issue** | **Affected Records** | **Action Taken** |
| :--- | :--- | :--- |
| Total Raw Records | 2,351 Records | Original dataset imported for data cleaning. |
| Duplicate Records | 21 Records | Removed duplicate records based on Ticket ID. |
| Missing Resolution Time | 1,911 Records | Retained as NULL for Open and In Progress tickets. |
| Missing First Response Time | 18 Records | Retained as NULL where first response data was unavailable. |
| Missing Interaction Count | 18 Records | Retained as NULL where interaction data was unavailable. |
| Text Inconsistencies | Multiple Columns | Standardized values across Status, Priority, Support Channel, and Issue Category columns. |
| Leading/Trailing Spaces | All Text Columns | Removed using Power Query Trim transformation. |
| Incorrect Data Types | 16 Columns | Disabled auto type detection and manually assigned data types. |
| Invalid Timestamp Sequence | 2 Records | Set invalid First Response Time values to NULL where they occurred before Created Time. |
| Agent Master Enrichment | 8 Agents | Merged Agent Joining Date using a separate Agent Master lookup table. |
| Unused Columns | 4 Columns | Removed Agent Group, Close Time, Latitude, and Longitude as they were not required for the project's business questions or analytical model. |
| Derived Columns Created | 6 Columns | Created Resolution Hours, First Response Minutes, FCR Flag, SLA Resolution Status, SLA First Response Status, and Experience Level. |
| Final Clean Records | 2,330 Records | Clean dataset prepared for SQL modeling and Power BI analysis. |


### Data Dictionary
| Field Name | Data Type | Description | Allowed Values | Example | Nullable |
|---|---|---|---|---|---|
| Status | Text | Current lifecycle status of the support ticket. | Open, In Progress, Resolved, Closed | Closed | No |
| Ticket ID | Text | Unique identifier assigned to each support ticket. | TID-xxxx | TID-10458 | No |
| Priority | Text | Business priority assigned to the ticket. | Low, Medium, High | High | No |
| Support Channel | Text | Channel through which the customer contacted support. | Chat, Email, Phone | Chat | No |
| Issue Category | Text | Primary issue reported by the customer. | Feature request, Product setup, etc. | Product setup | No |
| Agent Name | Text | Name of the support agent assigned to the ticket. | Valid Agent Names | Sheela Cutten | No |
| Created DateTime | Date/Time | Date and time when the support ticket was created. | Valid Date/Time | 2023-01-04 05:27:57 | No |
| SLA Resolve Due | Date/Time | Target resolution deadline based on the applicable SLA. | Valid Date/Time | 2023-01-04 16:41:11 | No |
| SLA First Response Due | Date/Time | Target deadline for providing the first response based on SLA. | Valid Date/Time | 2023-01-04 06:27:57 | No |
| Resolution DateTime | Date/Time | Timestamp when the ticket was resolved. | Valid Date/Time | 2023-01-07 13:17:12 | Yes |
| First Response DateTime | Date/Time | Timestamp when the customer received the first response from support. | Valid Date/Time | 2023-01-04 21:46:51 | Yes |
| Interaction Count | Whole Number | Total number of interactions between the customer and the assigned support agent. | Positive Integers | 3 | Yes |
| CSAT Score | Whole Number | Customer satisfaction rating provided after ticket closure. | Positive Integers (1 to 5) | 4 | Yes |
| Product Segment | Text | Product or service associated with the support request. | Service Categories | Custom software development | No |
| Support Tier | Text | Support tier responsible for handling the ticket. | Tier 1, Tier 2 | Tier 2 | No |
| Country | Text | Country from which the support request originated. | Valid Country Names | Italy | No |
| Resolution Hours | Decimal Number | Total time taken to resolve the ticket, calculated in hours. | Positive Decimal | 2.75 | Yes |
| First Response Minutes | Whole Number | Time taken to provide the first response, calculated in minutes. | Non-negative Integers | 7 | Yes |
| Single Touch Flag | Whole Number (0/1) | Indicates whether the ticket was resolved with a single interaction. | 0 = No, 1 = Yes | 1 | Yes |
| Res_SLA_Breach | Whole Number (0/1) | Indicates whether Resolution SLA was breached. | 0 = SLA Met, 1 = SLA Breached | 0 | Yes |
| FR_SLA_Breach | Whole Number (0/1) | Indicates whether First Response SLA was breached. | 0 = SLA Met, 1 = SLA Breached | 1 | Yes |
| Agent Joining Date | Date | Date when the support agent joined the organization. | Valid Dates | 2018-02-15 | No |
| Experience Level | Text | Agent experience category derived from the joining date. | Junior, Mid-Level, Senior | Senior | No |
## Data Model

Star schema built in MySQL, with an **Agent Master** table added at the modeling stage — agent joining dates were layered in as supplementary reference data to enable experience-based analysis:

| Table | Type | Purpose |
|---|---|---|
| `fact_support_tickets` | Fact | One row per ticket — ticket activity, timestamps, SLA outcomes, CSAT, FCR, and foreign keys to dimensions |
| `dim_agent` | Dimension | Agent details, joining date, and experience level |
| `dim_date` | Dimension | Date attributes used for time-based analysis |
| `dim_channel` | Dimension | Support channel details such as Email, Chat, and Call |
| `dim_category` | Dimension | Issue category and related classification |
| `dim_product` | Dimension | Product segment and product-related attributes |
| `dim_support_tier` | Dimension | Support tier information used to analyze service complexity and performance |
| `dim_priority` | Dimension | Ticket priority levels used for priority-based analysis |
| `dim_status` | Dimension | Ticket status such as Open, In Progress, Closed, and Resolved |
| `dim_country` | Dimension | Country/region information for geographical analysis |
| `base_measures` | Measures | Centralized DAX measures for KPIs and dashboard calculations |


The cleaned Excel workbook includes **Clean Data**, **Data Audit**, and **Data Dictionary** sheets.
An **Agent_Master_Table** was also created during the data modeling stage. Agent joining dates were added as **supplementary reference data** to enable experience-level analysis. Agents were classified as:

- **Junior** : 0–1 year of experience
- **Mid-level** : 1–3 years
- **Senior** : 3+ years

### Agent_Master_Table
| Agent Name | Agent Joining Date |
|---|---|
| Connor Danielovitch | 15-Feb-2018 |
| Sheela Cutten | 10-Jul-2019 |
| Bernard Beckley | 20-Nov-2019 |
| Adolpho Messingham | 15-May-2020 |
| Nicola Wane | 12-Mar-2021 |
| Kristos Westoll | 18-Oct-2021 |
| Michele Whyatt | 10-Apr-2022 |
| Heather Urry | 25-Sep-2022 |

## Key Findings
- **Product Setup, Pricing & Licensing, and Feature Requests** account for 67.5% of total ticket volume.
- Overall **Resolution SLA compliance is 80.9%**, indicating an opportunity to improve service consistency.
- **Email handles 53.0% of tickets** and has a higher average resolution time than Chat.
- **Tier 1 handles 76.0% of demand**, while Tier 2 shows better resolution performance and SLA compliance.
- **Senior agents have the highest average CSAT (3.70/5)**, highlighting the potential value of experience-based knowledge sharing and coaching.
  
## Deliverables
- Raw dataset
- Cleaned Excel workbook
- Clean CSV dataset
- MySQL scripts for database creation, data loading, star schema, and business analysis
- Power BI dashboard
- Business Insights Report
- Dashboard screenshots
  
## Repository Structure

```text
technical-support-operations-intelligence/
│
├── 01_Data/                                     
│   ├── 1_Technical Support - Raw Data.xlsx                         →  Raw source data
│   ├── 2_Technical Support - Clean Data.xlsx                       →  Cleaned data
│   └── 3_Technical Support - Import Data.csv                       →  Cleaned data in csv
│
├── 02_SQL/                                      
│   ├── 1_Create_Database.sql                                       →  database creation
│   ├── 2_Load_Raw_Data.sql                                         →  import csv file to table
│   ├── 3_Create_Star_Schema.sql                                    →  structure of star schema
│   ├── 4_Populate_Star_Schema.sql                                  →  data populate in star schema
|   ├── Technical_Support_SQL_Script.sql                            →  ALL IN ONE SQL FILE
│   └── Business_Queries/              
│       ├── Q01 ... Q08.sql                                         →  8 Business Queries SQL Scripts
│
├── 03_PowerBI/
│   └── Technical_Support_Operations_Intelligence_Dashboard.pbix    →  PowerBI dashboard
│   └── Technical_Support_Operations_Intelligence_Dashboard.pdf     →  PowerBI dashboard in PDF format
│
├── 04_Screenshots/
│   ├── 01_SQL_Queries/
        ├── Q01 ... Q08.png, Star_Schema.png                        →  SQL Queries Outputs and Star Schema in png
│   └──02_ PowerBI_Dashboard/
        ├── 01 ... 03.png, Star_Schema_and_Measures.png             →  PowerBI Dashboard images and Star Schema
│
├── 05_Business_Insights_and_Recommendations/
│   ├── Business_Insights.docx                                      →  Business Insights Report
│   └── Business_Insights.pdf                                       →  Business Insights Report in PDF
│
└── README.md                                                       →  Information about project
```

## Recommended Navigation
The project follows a numbered workflow where applicable:
**1. Data** → **2. SQL Database** → **3. SQL Analysis** → **4. Power BI** → **5. Insights**

## How to Reproduce

1. **Excel**: Open the cleaned workbook in `01_Data/2_Technical Support - Clean Data.xlsx ` to review the Clean Data, Data Audit, and Data Dictionary sheets.

2. **SQL**: Run the scripts in `02_SQL/` in order — `1_Create_Database.sql → 2_Load_Raw_Data.sql → 3_Create_Star_Schema.sql → 4_Populate_Star_Schema.sql` — against a MySQL instance. Alternatively, you can directly run `Technical_Support_SQL_Script.sql` at once. After that, run the 8 business queries

3. **Power BI**: Open ` Technical_Support_Operations_Intelligence_Dashboard` and refresh the data source to point at your MySQL instance or the cleaned CSV.

## Outcome
This project demonstrates a complete analytics workflow—from **data cleaning and validation to SQL database design, business analysis, Power BI visualization, and business recommendations**—transforming operational support data into actionable insights.






