# Development notes

- All the code in this repository is provided ​“AS IS” and the author (Peter Lalovsky, zPL Concept Inc.) makes no warranties, express or implied, and hereby disclaims all implied warranties, including any warranty of merchantability and warranty of fitness for a particular purpose.
- The code in this repository is **parametrized [Fabric](https://www.microsoft.com/en-us/microsoft-fabric) framework**, i.e. ETL, that:
  - Extracts from various sources
  - Creates dinamically [bronze, silver and gold layers](https://learn.microsoft.com/en-us/azure/databricks/lakehouse/medallion)
  - Create and refresh Power BI Semantic Models
- Currently Development work is done only on *bronze*
- Everything is in DEV and TEST stage
- The design and the architecture of the entire solution is subject of constant evolution

# Documentation
You can find more information on my [blog](https://peter.lalovsky.com/tag/fabric-framework)

# Naming Convention [^1]

Prefix | Description
:--- | :---
lh | Lakehouse  
pl | Pipeline  
nb | Notebook  
sdf | Spark Dataframe  
pdf | Pandas Dataframe  
eo | Extract Object (lh_cfg.eo_sqlserver, lh_cfg.eo_json)  
ep | Extract Parameter (lh_cfg_ep_sqlserver, lh_cfg.ep_json)  
pbi | Power BI (lh_cfg.pbi_refresh)  
md | Meta data (lh_cfg.md_column)

[^1]: The names of all the objects are in singular

# Folders

- /bronze --> All the objects, related to the *bronze* layer
  - /test --> Notebooks to test the *bronze* notebooks
    - nb_bronze_function_extract_csv_test.ipynb
    - nb_bronze_function_extract_excel_test.ipynb
    - nb_bronze_function_extract_json_test.ipynb
    - nb_bronze_function_extract_lakehouse_sql_server_test.ipynb
    - nb_bronze_function_test.ipynb
  - nb_bronze_function.ipynb --> Functions, related to the *Bronze* layer
  - nb_bronze_function_extract_api.ipynb --> Extract from REST API
  - nb_bronze_function_extract_api_pl.ipynb --> Extract from REST API
  - nb_bronze_function_extract_csv.ipynb --> Extract from CSV
  - nb_bronze_function_extract_excel.ipynb --> Extract from Excel
  - nb_bronze_function_extract_json.ipynb --> Extract from JSON
  - nb_bronze_function_extract_lakehouse_sql_server.ipynb --> Extract from SQL Server
  - nb_bronze_master.ipynb --> The master notebook for *bronze*. Calls all the other notebooks. Called from "pl_master"

- /gold
  - nb_gold_master.ipynb --> The master notebook for *gold*. Calls all the other notebooks. Called from "pl_master"

- /one_time_exec --> Run the following in order to create the initial objects
  - nb_create_lakehouse.ipynb --> create:
    - Lakehouses (cfg, log, bronze, silver, shortcut_1, other)
    - ABFS paths
    - Tables (extract object, extract parameter, power bi refresh, metedata, log, schedule, etc.)
  - configuration.xlsx --> All the configuration for the framework. Paste in "lh_cfg/Files"
  - extract_schema_table_column_from_src_server.sql - Extract the data, needed in configuration.xlsx, related to on-prem SQL Server
  - nb_insert_into_lakehouse.ipynb --> Copy/paste from "configuration.xlsx" to the framework system tables
  - nb_create_gold_warehouse.ipynb --> Create warehouse *gold*
  
- pl_master *(triggered pipeline)*
  - get_global_parameter --> read from "lh_cfg.dbo.global_parameter"
  - nb_bronze_master.ipynb --> Call "bronze/nb_bronze_master.ipynb"
  - nb_silver_master.ipynb --> Call "silver/nb_silver_master.ipynb"
  - nb_gold_master.ipynb --> Call "gold/nb_gold_master.ipynb"
  - nb_power_bi_master.ipynb --> Call "power_bi/nb_power_bi_master.ipynb"
  - nb_report_master.ipynb --> Call "report/nb_report_master.ipynb"
  - if_send_success_email --> Send *success* email(s)
  - if_send_error_email --> Send *error* email(s)
  
- /power_bi
  - /refresh
    - nb_refresh_dataset_2.ipynb --> Refresh Power BI Semantic Models
    
  - /report *(empty)* --> Power BI Reports
    
  - /semantic_model *(empty)* --> Power BI Semantic Models
    
  - nb_power_bi_function.ipynb --> The functions, related to *Power BI Refresh*
  - nb_power_bi_master.ipynb --> The master notebook for *Power BI Refresh*. Calls all the other notebooks. Called from *pl_master*
  
- /recovery --> Notebooks for *disaster recovery*
  - Info.txt

- /report --> Notebooks that create HTML report from lh_log and return it to the calling pipeline
  - /test
    - nb_report_function_test.ipynb
    
  - nb_report_function.ipynb
  - nb_report_master.ipynb
  
- /silver --> Notebooks, related to the *silver* layer
  - nb_silver_function.ipynb
  - nb_silver_master.ipynb
  
- /system
  - /test
    - nb_system_function_test.ipynb
  
  - nb_system_cfg.ipynb
  - nb_system_function.ipynb --> *System* functions, i.e. used in multiple layers (bronze, silver, etc.). Example: get *now*, insert into *log*, *spark.sql*, etc.
  
- /working_files
  - /sample_data --> sample files to run tests
    - /CSV
      - /folder 16
        - /other folder 27
          - sample 2.csv
      - /folder 35
        - people.csv
      - clients.csv
      - customérs.csv
    
    - /Excel
      - /Other
        - /Thing
          - Third test.xlsx
      - /Réference Data
        - Test.xlsx
      - /Other test.xlsx

    - /JSON
      - /folder 2
        - pl_test_1_2.json
      - pl_test_1_1.json

  - /schedule
    - schedule_config_table.ods --> Future table for schedules to replace "Frequency" logic
  
  JSON Structure.xlsx --> Help to understand the structure and how to fill sheet *"*Bronze (JSON)* in file *"*one_time_exec/configuration.xlsx*
  
  Mirrored Azure SQL Database.txt --> How to use mirrored database in Fabric

Readme.md - this file

# Installation

- Copy/Paste the folders/files in Fabric Workspace
- Run notebook "one_time_exec/nb_create_lakehouse"
- Upload file "configuration.xlsx" to "lh_cfg/Files"
- Run notebook "one_time_exec/nb_insert_into_lakehouse"
- Run notebook "one_time_exec/nb_create_gold_warehouse"
- Open pipeline "pl_master" and add a schedule for every hour