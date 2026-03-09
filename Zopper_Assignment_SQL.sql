                                        -- Zopper  Assignment : Car Insurance Policies --

-- Creating Policy Sales Table
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

-- Creating  Claims Data Table

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

--Show data 

select * from policy_sales_data;
select * from claims_data;

-- Analytical Queries

--1. Calculate the total premium collected during the year 2024.

select sum(premium)as Total_premium from policy_sales_data;

--2. Calculate the total claim cost for each year (2025 and 2026) with a monthly breakdown.

select 
	extract(year from claim_date)as Years,
	extract(month from claim_date)as Months,
	sum(claim_amount)as Total_Claim
from claims_data
group by extract(year from claim_date),
		extract(month from claim_date)
order by extract(year from claim_date) ,
		extract(month from claim_date);

--3. Calculate the claim cost to premium ratio for each policy tenure (1, 2, 3, and 4 years).

select p.policy_tenure ,round(sum(c.claim_amount)/sum(distinct p.premium),2)as Ratio from  policy_sales_data as p
join claims_data as c
on p.customer_id=c.customer_id
group by p.policy_tenure;

--4. Calculate the claim cost to premium ratio by the month in which the policy was sold
--(January–December 2024).

select 
	extract(month from p.policy_purchase_date)as month ,
	round(sum(c.claim_amount)/sum(distinct p.premium),2)as Ratio 
from  policy_sales_data as p
join claims_data as c
on p.customer_id=c.customer_id
group by extract(month from p.policy_purchase_date);

--5. If every vehicle that has not yet made a claim eventually files exactly one claim during the
--remaining policy tenure, estimate the total potential claim liability.

select 
	count(*) * 10000 as total_future_claim_liability
from  policy_sales_data as p
left join claims_data as c
on p.customer_id=c.customer_id
where  c.vehicle_id is null;

/*6. Assume daily premium = Total Premium ÷ Total Policy Tenure Days. Based on this:
• Calculate the premium already earned by the company up to February 28, 2026.
• Estimate the premium expected to be earned monthly for the remaining policy period
(assume 46 months remaining).*/

select sum((premium/(policy_end_date-policy_start_date)) *
    (case 
  			when policy_end_date <= date '2026-02-28' 
            then policy_end_date-policy_start_date
            else date '2026-02-28'-policy_start_date
            end
    )) as earned_premium
from policy_sales_data
where policy_start_date <= date '2026-02-28';

-- Bonus Questions

--1. Identify which policy tenure appears most profitable and explain why.

select 
    p.policy_tenure,
    sum(p.premium) as total_premium,
    sum(c.claim_amount) as total_claims,
    sum(p.premium) - sum(c.claim_amount) as profit
from policy_sales_data p
left join claims_data c
on p.customer_id = c.customer_id
group by p.policy_tenure
order by profit desc;
--3 year tenure appears most profitable or least unprofitabl

--2. Estimate the loss ratio (Claims ÷ Premium) for the portfolio.

select 
    round(sum(c.claim_amount)/sum(p.premium),2) as loss_ratio
from policy_sales_data p
left join claims_data c
on p.customer_id = c.customer_id;

4. If claim frequency increases by 5% annually, estimate the impact on future profitability

select 
    sum(claim_amount) as current_claims,
    sum(claim_amount) * 1.05 as next_year_claims,  --5% = 0.05 > 100% + 5% = 105% > 105 / 100 = 1.05
    sum(claim_amount) * 1.1025 as two_year_claims
from claims_data;


--Short Document Explaining My Approach and Assumptions
--Approach

/*

>First, I created a Policy Sales dataset for 1,000,000 customers in 2024. 
Policies were distributed evenly across all days of the year. 
I assigned policy tenures based on the given percentages: 20% for 1 year, 30% for 2 years, 40% for 3 years, and 10% for 4 years. 

>I calculated the policy start date by adding 365 days to the purchase date. 
Then I calculated the policy end date based on the policy tenure.

>Next, I created the Claims dataset based on the rules in the assignment. 
In 2025, only vehicles purchased on the 7th, 14th, 21st, and 28th of each month could file claims, 
and 30% of those vehicles filed a claim on the policy start date. 

>For 2026, 10% of vehicles with 4-year policies filed claims, 
and these claims were distributed evenly between January 1 and February 28, 2026. 

>After creating the datasets, I used SQL queries to calculate total premium, claim costs, claim ratios, 
and future claim liability.

--Assumptions

Each vehicle value is ₹100,000.

Claim amount is 10% of vehicle value (₹10,000).

Premium is ₹100 per year of policy tenure.

Policies are evenly distributed across all days in 2024.

Each vehicle can file only one claim per year.

Claims are only allowed when the policy is active.*/


--Key Insights from the Analysis

/*

The company sold 1,000,000 policies in 2024, generating significant premium revenue.

3-year policies (40%) form the largest share of the portfolio.

Claims in 2025 happen only on specific purchase dates, creating clear claim spikes during those months.

4-year policies generate the highest premium per policy, which may improve profitability.

Claims in 2026 are limited to only 4-year policies, which spreads risk across a longer time period.

If all remaining vehicles eventually file a claim, the company may face high future claim liability,
so pricing and risk management are important.

--END