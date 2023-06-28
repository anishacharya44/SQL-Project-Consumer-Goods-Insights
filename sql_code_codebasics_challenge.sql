# Q1
select distinct(market) from dim_customer where customer = 'Atliq Exclusive' and region = 'APAC' order by market;

# Q2
select fiscal_year, count(product_code) as cnt_distinct, (count(product_code) - lag(count(product_code)) over (order by fiscal_year))/lag(count(product_code)) over (order by fiscal_year)*100 as pert_chng from fact_gross_price group by fiscal_year;

# Q3
select segment, count(product_code) as product_count from dim_product group by segment order by product_count desc;

# Q4
with t1 as
(select segment, count(dp.product_code) as cnt20, fiscal_year from dim_product dp inner join fact_gross_price fp on dp.product_code = fp.product_code
group by segment,fiscal_year having fiscal_year = 2020),
t2 as
(select segment, count(dp.product_code) as cnt21, fiscal_year from dim_product dp inner join fact_gross_price fp on dp.product_code = fp.product_code
group by segment,fiscal_year having fiscal_year = 2021)
select t1.segment, t1.cnt20 as unique_2020, t2.cnt21 as unique_2021, t2.cnt21 - t1.cnt20 as Diff from t1 inner join t2 on t1.segment = t2.segment order by t1.segment;

# Q5
(select fc.product_code, dp.product, fc.manufacturing_cost as cost from fact_manufacturing_cost fc inner join dim_product dp on fc.product_code = dp.product_code 
group by fc.product_code order by cost desc limit 1)
union 
(select fc.product_code, dp.product, fc.manufacturing_cost as cost from fact_manufacturing_cost fc inner join dim_product dp on fc.product_code = dp.product_code 
group by fc.product_code order by cost limit 1);

# Q6
select dc.customer_code, customer, avg(pre_invoice_discount_pct) as avg_discount from dim_customer dc inner join fact_pre_invoice_deductions fd on dc.customer_code = fd.customer_code
where fiscal_year = 2021 and market = 'India' group by dc.customer_code order by avg_discount desc limit 5;

# Q7
with t3 as
(select fm.product_code, monthname(date) as mnth, fm.fiscal_year, sum(sold_quantity), fp.gross_price, sum(sold_quantity)*fp.gross_price as total_price 
from fact_sales_monthly fm inner join dim_customer dc on fm.customer_code = dc.customer_code inner join fact_gross_price fp on fm.product_code = fp.product_code and fm.fiscal_year = fp.fiscal_year 
where customer = 'Atliq Exclusive' group by fm.product_code, mnth, fm.fiscal_year)
select t3.mnth, t3.fiscal_year, round(sum(total_price),2) as gross_sales from t3 group by t3.mnth, t3.fiscal_year;

# Q8
select case 
when month(date) in (9,10,11)  then 1
when month(date) in (12,1,2) then 2
when month(date) in (3,4,5) then 3
else 4
end as 'Qt', sum(sold_quantity) as total_units
from fact_sales_monthly where fiscal_year = 2020 group by Qt order by total_units desc;

# Q9
with t4 as
(select channel, round(sum(sold_quantity*gross_price),2) as total_gross_sales from fact_sales_monthly fm inner join dim_customer dc on fm.customer_code = dc.customer_code inner join fact_gross_price fp on fm.product_code = fp.product_code and fm.fiscal_year = fp.fiscal_year
where fm.fiscal_year = 2021 group by channel),

t5 as
(select sum(t4.total_gross_sales) as total_sales from t4)

select t4.channel, t4.total_gross_sales, round((t4.total_gross_sales/t5.total_sales)*100,2) as percentage from t4,t5 order by t4.total_gross_sales desc;

# Q10
with t6 as
(select division, dp.product_code, product, sum(sold_quantity) as total_prod_sold, dense_rank() over(partition by division order by sum(sold_quantity) desc) as sales_rank 
from dim_product dp inner join fact_sales_monthly fm on dp.product_code = fm.product_code
where fiscal_year = 2021 group by product_code, division)
select t6.division, t6.product_code, t6.product, t6.total_prod_sold, t6.sales_rank from t6 where sales_rank in (1,2,3);

