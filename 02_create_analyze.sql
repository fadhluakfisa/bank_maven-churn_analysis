-- View the tables:
SELECT * FROM bank_churn;

-- Analyze: What attributes are more common among churner than non-churners?

-- 1. How many churners and non-churners?
SELECT CASE WHEN exited = 1 THEN 'Churn' ELSE 'Non-Churn' END AS churn_status,
	   COUNT(*) AS total_customers,
       ROUND(COUNT(*) * 100 / SUM(COUNT(*)) OVER(),2) AS customers_rate
FROM bank_churn
GROUP BY churn_status;
-- Result: churners are 20.37%

-- 2. How tenure's long is affecting to churn rate?
SELECT
	   CASE WHEN tenure = 0 THEN '0 year' ELSE (CONCAT(tenure, ' years')) END AS tenure,
       ROUND(AVG(exited) *100, 2) AS churn_rate
FROM bank_churn
GROUP BY tenure
ORDER BY churn_rate DESC;
-- Result: in 0 to 1 year tenure, the churn rate has increased 22% to 23%

-- 3. How the credit score is affecting to churn rate?
WITH segmen AS
	(SELECT exited,
		CASE WHEN credit_score BETWEEN 350 AND 579 THEN 'Poor'
	         WHEN credit_score BETWEEN 580 AND 669 THEN 'Fair'
             WHEN credit_score BETWEEN 670 AND 739 THEN 'Good'
             WHEN credit_score BETWEEN 740 AND 799 THEN 'Very Good'
             ELSE 'Exceptional' END AS credit_segmen,
		 CASE WHEN est_salary < 15000 THEN 'Low Income'
			  WHEN est_salary BETWEEN 15000 AND 50000 THEN 'Lower Middle Income'
			  WHEN est_salary BETWEEN 50001 AND 100000 THEN 'Upper Middle Income'
			  WHEN est_salary BETWEEN 100001 AND 150000 THEN 'High Income'
			  ELSE 'Top Earners' END AS salary_segmen
       FROM bank_churn)

SELECT credit_segmen, salary_segmen, bad_debt_risk,
       ROUND(AVG(exited) * 100,2) AS churn_rate
FROM (SELECT exited, credit_segmen, salary_segmen,
	  CASE WHEN credit_segmen = 'Poor' AND salary_segmen IN ('Low Income', 'High Income','Top Earners') THEN 'High Risk'
			WHEN credit_segmen = 'Poor' AND salary_segmen IN ('Upper Middle Income','Lower Middle Income') THEN 'Moderate Risk'
            WHEN credit_segmen = 'Fair' THEN 'Attention Required'
            ELSE 'Low Risk' END AS bad_debt_risk
	   FROM segmen) AS risk_matrix
GROUP BY bad_debt_risk, credit_segmen, salary_segmen
ORDER BY churn_rate DESC;
-- a. the exceptional credit score with lower middle income have highest churn rate
-- b. both top earners and high income have poor credit segmen and contributed to the second and third-highest churn rate

-- Conclusion of prediction: 
-- a. this segmentation likely to switch their bank to other financial instutition because the other banks offer lower fee credit that their current income based tier 
-- b. these segmentation might intentionally settle or restructure their debts at a discount before migrating to other institutions to start a new credit cycle, 
--    exploiting the time-lag or negotiation policies of the bank, this behavior results in a direct loss of projected interest income and necessitates a higher Allowance for Doubtful Accounts

-- solution:
-- a. give lower fee for exceptional credit score with 1% lower interest than average competitors for 3 months credit with limit maximum debts (10% lower than average competitors)
-- b. give lower interest rate, give early warning at fair credit score and limit the credit features

-- How many consumers who are active members of credit card:
WITH segmen AS
	(SELECT exited, is_active_memb, has_creditcard,
		CASE WHEN credit_score BETWEEN 350 AND 579 THEN 'Poor'
	         WHEN credit_score BETWEEN 580 AND 669 THEN 'Fair'
             WHEN credit_score BETWEEN 670 AND 739 THEN 'Good'
             WHEN credit_score BETWEEN 740 AND 799 THEN 'Very Good'
             ELSE 'Exceptional' END AS credit_segmen,
		 CASE WHEN est_salary < 15000 THEN 'Low Income'
			  WHEN est_salary BETWEEN 15000 AND 50000 THEN 'Lower Middle Income'
			  WHEN est_salary BETWEEN 50001 AND 100000 THEN 'Upper Middle Income'
			  WHEN est_salary BETWEEN 100001 AND 150000 THEN 'High Income'
			  ELSE 'Top Earners' END AS salary_segmen
	  FROM bank_churn)
SELECT  credit_segmen, salary_segmen,
		SUM(CASE WHEN has_creditcard = 1 AND is_active_memb = 1 THEN 1 ELSE 0 END) AS active_credit_memb,
        ROUND(AVG(exited)*100,2) AS churn_rate
FROM segmen
GROUP BY credit_segmen, salary_segmen
ORDER BY churn_rate DESC;

-- 4. Do the top earners use the bank as their primary saving & How the salary is affecting to churn rate?
WITH salary AS 
		(SELECT 
			CASE WHEN est_salary < 15000 THEN 'Low Income'
				 WHEN est_salary BETWEEN 15000 AND 50000 THEN 'Lower Middle Income'
                 WHEN est_salary BETWEEN 50001 AND 100000 THEN 'Upper Middle Income'
                 WHEN est_salary BETWEEN 100001 AND 150000 THEN 'High Income'
                 ELSE 'Top Earners' END AS salary_segmentation,
			ROUND(AVG(exited) *100,2) AS churn_rate,
            ROUND(AVG(balance/est_salary),2) AS avg_spenders -- saving to salary ratio
		FROM bank_churn
		GROUP BY salary_segmentation
		ORDER BY churn_rate DESC)
SELECT salary_segmentation, churn_rate, avg_spenders
FROM salary
ORDER BY churn_rate DESC;
-- Result: 
-- a. the top earners have contributed rs of top earners is the lowest among the other salary segmentation

-- conclusion of prediction: the top earners likely transfer their wealth into other financial instituions that offer more for their credit spending

-- solution: 
-- a. the bank need to see the average of maximum credit limit from competitors and lowering the maximum limit credit, but higher than competitor little bit
-- b. to prevent the bank is only be their 'transit' station, the bank need to give a free transfer fee at certain amount of saving for average months
-- c. benchmark credit: +10% limit credit for min 5% spending

-- 5. How number of products customers using is affecting to churn rate
WITH segmen AS
	(SELECT exited, est_salary, num_products, has_creditcard, is_active_memb,
		 CASE WHEN est_salary < 15000 THEN 'Low Income'
			  WHEN est_salary BETWEEN 15000 AND 50000 THEN 'Lower Middle Income'
			  WHEN est_salary BETWEEN 50001 AND 100000 THEN 'Upper Middle Income'
			  WHEN est_salary BETWEEN 100001 AND 150000 THEN 'High Income'
			  ELSE 'Top Earners' END AS salary_segmen,
		  CASE WHEN credit_score BETWEEN 350 AND 579 THEN 'Poor'
	         WHEN credit_score BETWEEN 580 AND 669 THEN 'Fair'
             WHEN credit_score BETWEEN 670 AND 739 THEN 'Good'
             WHEN credit_score BETWEEN 740 AND 799 THEN 'Very Good'
             ELSE 'Exceptional' END AS credit_segmen
	  FROM bank_churn)
      
SELECT salary_segmen, credit_segmen, num_products,
	   ROUND(SUM(CASE WHEN has_creditcard = 1 AND is_active_memb = 1 THEN 1 ELSE 0 END) /
	       NULLIF(SUM(has_creditcard),0)*100,2) AS credit_active,
	   ROUND(avg(est_salary/num_products),0) AS income_product_rate
FROM segmen
GROUP BY salary_segmen, credit_segmen, num_products
ORDER BY income_product_rate DESC;
-- Result: the top earners have contributed to highest income product ratio which is every 1 product price that they can pay at certain amount of their balance
-- conclusion of prediction: the top earners only use 1 of bank products from every credit segmentation which means bank not offer any interesting products
-- solution: offer the 7% lower interest rate than average competitors for 3 months for very good to exceptional segmen with 2x longer than average competitor,
-- and 4-5% for fair to poor with 3 months payment due

-- 1. How many customers per country, age and gender
SELECT geography,
	   CASE WHEN age < 30 THEN 'Young Adults'
			WHEN age BETWEEN 30 AND 50 THEN 'Adults'
            ELSE 'Senior' END AS age_segmentation,
		gender,
        COUNT(*) AS total_customers,
        ROUND(SUM(CASE WHEN exited = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS churn_rate
FROM bank_churn
GROUP BY geography, age_segmentation, gender
ORDER BY geography, age_segmentation;


-- 2. How many customers active using credit card per geography and age segmentation with poor credit score
WITH segmen AS
	(SELECT exited, geography, age, has_creditcard, is_active_memb,
		 CASE WHEN est_salary < 15000 THEN 'Low Income'
			  WHEN est_salary BETWEEN 15000 AND 50000 THEN 'Lower Middle Income'
			  WHEN est_salary BETWEEN 50001 AND 100000 THEN 'Upper Middle Income'
			  WHEN est_salary BETWEEN 100001 AND 150000 THEN 'High Income'
			  ELSE 'Top Earners' END AS salary_segmen,
		  CASE WHEN credit_score BETWEEN 350 AND 579 THEN 'Poor'
	         WHEN credit_score BETWEEN 580 AND 669 THEN 'Fair'
             WHEN credit_score BETWEEN 670 AND 739 THEN 'Good'
             WHEN credit_score BETWEEN 740 AND 799 THEN 'Very Good'
             ELSE 'Exceptional' END AS credit_segmen
	  FROM bank_churn),
customer AS (SELECT *,
				CASE WHEN age < 30 THEN 'Young Adults'
					 WHEN age BETWEEN 30 AND 50 THEN 'Adults'
					 ELSE 'Senior' END AS age_segmentation
			  FROM segmen)
              
SELECT age_segmentation, credit_segmen,
		ROUND(SUM(CASE WHEN has_creditcard = 1 AND is_active_memb = 1 THEN 1 ELSE 0 END) / NULLIF(SUM(has_creditcard),0)*100,2) AS credit_active,
		ROUND(AVG(exited) *100,2) AS churn_rate
FROM customer
WHERE credit_segmen = 'Poor' AND salary_segmen IN ('Top Earners','High Income')
GROUP BY age_segmentation, credit_segmen
ORDER BY churn_rate DESC;
-- Result: most credit active segmentation is senior and france 
-- conclusion: because the tax of France is the highest among the other countries here, the senior customers have difficulties to pay due their debts 
-- prediction: the customers likely to move their balance into other financial instituition