# Zopper-Assignment
# Zopper Assignment – Car Insurance Policies Analysis

## Project Overview

This project simulates a **Car Insurance Portfolio** and analyzes policy sales and claims data using SQL.

The goal is to understand:

- Premium collection
- Claim costs
- Profitability by policy tenure
- Future claim liabilities
- Loss ratio of the portfolio
- Impact of increasing claim frequency

The analysis is performed using **SQL queries on simulated datasets**.

---

# Database Schema Setup

## Policy Sales Table

```sql
CREATE TABLE policy_sales_data (
    customer_id BIGINT PRIMARY KEY,
    vehicle_id BIGINT UNIQUE,
    vehicle_value NUMERIC(12,2),
    premium NUMERIC(10,2),
    policy_purchase_date DATE,
    policy_start_date DATE,
    policy_end_date DATE,
    policy_tenure INTEGER
);
Claims Data Table
CREATE TABLE claims_data (
    claim_id BIGINT PRIMARY KEY,
    customer_id BIGINT,
    vehicle_id BIGINT,
    claim_amount NUMERIC(12,2),
    claim_date DATE,
    claim_type INTEGER,

    FOREIGN KEY (customer_id) REFERENCES policy_sales_data(customer_id),
    FOREIGN KEY (vehicle_id) REFERENCES policy_sales_data(vehicle_id)
);
Analytical Queries
1. Total Premium Collected in 2024
SELECT sum(premium) AS total_premium
FROM policy_sales_data;
2. Total Claim Cost by Year and Month
SELECT 
    extract(year from claim_date) AS years,
    extract(month from claim_date) AS months,
    sum(claim_amount) AS total_claim
FROM claims_data
GROUP BY 
    extract(year from claim_date),
    extract(month from claim_date)
ORDER BY 
    extract(year from claim_date),
    extract(month from claim_date);
3. Claim Cost to Premium Ratio by Policy Tenure
SELECT 
    p.policy_tenure,
    round(sum(c.claim_amount)/sum(DISTINCT p.premium),2) AS ratio
FROM policy_sales_data AS p
JOIN claims_data AS c 
ON p.customer_id = c.customer_id
GROUP BY p.policy_tenure;
4. Claim Ratio by Policy Purchase Month
SELECT 
    extract(month from p.policy_purchase_date) AS month,
    round(sum(c.claim_amount)/sum(DISTINCT p.premium),2) AS ratio
FROM policy_sales_data AS p
JOIN claims_data AS c 
ON p.customer_id = c.customer_id
GROUP BY extract(month from p.policy_purchase_date);
5. Estimate Total Potential Future Claim Liability

If every vehicle that has not yet filed a claim eventually files one claim:

SELECT 
    count(*) * 10000 AS total_future_claim_liability
FROM policy_sales_data AS p
LEFT JOIN claims_data AS c 
ON p.customer_id = c.customer_id
WHERE c.vehicle_id IS NULL;
6. Calculate Earned Premium Until Feb 28, 2026

Daily Premium Formula:

Daily Premium = Total Premium / Policy Tenure Days
SELECT 
    sum((premium/(policy_end_date-policy_start_date)) *
    (CASE 
        WHEN policy_end_date <= DATE '2026-02-28'
        THEN policy_end_date-policy_start_date
        ELSE DATE '2026-02-28'-policy_start_date
    END)) AS earned_premium
FROM policy_sales_data
WHERE policy_start_date <= DATE '2026-02-28';
Bonus Analysis
1. Identify the Most Profitable Policy Tenure
SELECT 
    p.policy_tenure,
    sum(p.premium) AS total_premium,
    sum(c.claim_amount) AS total_claims,
    sum(p.premium) - sum(c.claim_amount) AS profit
FROM policy_sales_data p
LEFT JOIN claims_data c 
ON p.customer_id = c.customer_id
GROUP BY p.policy_tenure
ORDER BY profit DESC;

Insight:
The 3-year tenure appears most profitable (or least unprofitable) compared to other policy durations.

2. Estimate Portfolio Loss Ratio

Loss Ratio Formula:

Loss Ratio = Claims ÷ Premium
SELECT 
    round(sum(c.claim_amount)/sum(p.premium),2) AS loss_ratio
FROM policy_sales_data p
LEFT JOIN claims_data c 
ON p.customer_id = c.customer_id;
3. Impact if Claim Frequency Increases by 5% Annually
SELECT 
    sum(claim_amount) AS current_claims,
    sum(claim_amount) * 1.05 AS next_year_claims,
    sum(claim_amount) * 1.1025 AS two_year_claims
FROM claims_data;

This estimates how increasing claim frequency affects future claim costs and profitability.

Approach and Assumptions
Approach

Generated 1,000,000 policy records for 2024.

Policies were evenly distributed across all days of the year.

Policy tenures were assigned according to the required distribution:

Tenure	Percentage
1 year	20%
2 years	30%
3 years	40%
4 years	10%

Policy start date = Purchase Date + 365 days

Policy end date calculated based on policy tenure.

Claims Simulation

2025 Claims

Only vehicles purchased on:

7th

14th

21st

28th

30% of those vehicles filed a claim

Claim date = policy start date

2026 Claims

10% of vehicles with 4-year policies filed claims

Claims distributed evenly between:

Jan 1, 2026 → Feb 28, 2026
Assumptions

Vehicle value = ₹100,000

Claim amount = 10% of vehicle value = ₹10,000

Premium = ₹100 per year of policy tenure

Policies distributed evenly across 2024

Each vehicle files maximum one claim per year

Claims only occur when the policy is active

Key Insights

The company sold 1,000,000 insurance policies in 2024.

3-year policies form the largest share (40%) of the portfolio.

Claims in 2025 occur only on specific purchase dates, creating noticeable claim spikes.

4-year policies generate the highest premium per policy.

Claims in 2026 occur only for 4-year policies, spreading risk across longer tenures.

If all remaining vehicles eventually file claims, the company could face significant future claim liability, making pricing and risk management critical.
