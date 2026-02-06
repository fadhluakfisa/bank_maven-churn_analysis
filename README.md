# bank_maven-churn_analysis
This project analyzes causes of customer churn with focuses comparing the countries, salary segmentation, age segmentation, and credit segmentation.
The source of this project is from mavenanalytics

## File structure:
- **01_create_database.sql**: The query to initiate the database, table, and import data.
- **02_create_analyze.sql**: The query to analyze the data and find the insights.
- **bank_churn.csv**: The original data.
- **bank_churn.pbix**: The dashboard to visualize the data.

## Key Insights:
1. **Country Impact**: This analyzes the impact of the tax rate in every country on churn rate and credit score.
    - France: Tax rate 30%
    - Germany: Tax rate 26%
    - Spain: Tax rate 19%
2. **Saving analysis**: Identifying the bank balance based on the customers'income by salary segmentation.
3. **Credit active**: Identifying how many customers are active in using their credit cards.
4. **Churn analysis**: Identifying how many customers exited from the bank based on the segmentation.

## How to use:
1. Open the script **01_create_database.sql**
2. Use the **02_create_analyze.sql**
3. Open the power BI file **bank_churn.pbix**
