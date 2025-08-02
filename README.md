# Project Background
Amazon, founded in 1994, is a global e-commerce and technology leader operating in sectors such as retail, cloud computing, logistics, and digital streaming. With nearly three decades of operation, the company has evolved from an online bookstore into a multinational conglomerate serving millions of customers daily.

As a data analyst at Amazon, my role centers on extracting actionable insights from vast volumes of operational data to support strategic decisions across various departments. This project focuses specifically on analyzing key performance metrics from Amazon’s sales and supply chain operations over a given period.

Insights and recommendations are provided on the following key areas:

- **Overview:** A general summary of total orders, quantities, order statuses, product categories, and top-performing states in Quarter 2.
- **Sales:**  Identifying trends in order volume, item quantity, category-size preferences, daily purchasing behavior, and state-level demand.
- **Supply Chain:** Evaluating package status, fulfillment methods, shipping efficiency, and regional differences in delivery performance.

The SQL queries used to inspect and clean the data for this analysis can be found here [link].

An interactive Tableau dashboard used to report and explore sales trends can be found here [link].



# Executive Summary

### Overview of Findings

- In Quarter 2, the company recorded 120,000 total orders, 116,000 units sold, and a total revenue of ₹79.55 million. While the numbers may seem solid at first glance, a deeper look reveals several anomalies and critical insights that highlight operational challenges.
- First, there is a data anomaly where total quantity < total orders, likely due to cancelled orders where quantity resets to zero. This points to potential data handling or order processing issues.
- The overall monthly performance showed a consistent decline from April to June, suggesting possible seasonal trends or decreased customer demand. However, more importantly, only 22.07% of orders were successfully delivered, while a staggering 61.98% (74,423 orders) remained in “Ongoing” status as of the reporting date.
- Notably, among the 74,423 ongoing orders, a significant portion originated from April and May. Since the total order count in June was 35,170, this implies that nearly 39,000 orders from earlier months had yet to be completed even after one month or more, pointing to substantial fulfillment and logistics delays.
- From a customer behavior standpoint, non-business customers dominate, with a clear preference for purchasing through Amazon.in. This channel drives the bulk of order volume, especially in the B2C space.
- Lastly, in terms of product performance, T-shirts and Shirts dominate in both quantity and total amount, indicating strong customer demand in the casual wear category.

![image alt](https://github.com/nthanhthao01/Amazon-Project/blob/main/Overview.png?raw=true)

# Insights Deep Dive
### Sales:

* Sales activity remained relatively stable throughout the week, with both total orders and revenue dipping slightly on Thursday before rebounding by Sunday. The average quantity per order (0.97) and average amount per order (₹662.55) were affected by cancelled orders, as such entries typically reset their quantity and value to zero.
  
* Consumer behavior showed a clear preference for T-shirts and Shirts, especially in sizes S to 3XL. These two categories consistently led purchase volumes across most Indian states, notably Karnataka, Andhra Pradesh, and Tamil Nadu. Additionally, the trend between order quantity and order value was positively correlated, suggesting a stable value-per-item ratio across transactions.

![image alt](https://github.com/nthanhthao01/Amazon-Project/blob/main/Sales.png?raw=true)


### Supply Chain:

* Total package volume declined month-over-month, which correlates with the drop in total orders observed in the Sales dashboard. Most packages were still shipped * Total package volume declined month-over-month, which correlates with the drop in total orders observed in the Sales dashboard. Most packages were still shipped out successfully, indicating stable outbound operations. However, it is important to note that an order may consist of multiple packages, and the failure of a single package can result in the entire order being marked as unsuccessful. This may partly explain why, despite consistent shipping activity, nearly 39,000 orders from April and May remained incomplete by the end of June — highlighting ongoing challenges in fulfillment and logistics efficiency.
  
* Expedited shipping accounted for 2–3 times more volume than Standard across all states, particularly in high-demand regions like Maharashtra, Karnataka, and Andhra Pradesh. Notably, Expedited orders are fulfilled by Amazon, while Standard orders are typically merchant-fulfilled, highlighting a split in fulfillment responsibility.
  
* T-shirts and Shirts remained the most frequently shipped categories—aligning with overall sales trends—but also showed higher counts in ‘Unshipped’ and ‘Cancelled’ statuses.

![image alt](https://github.com/nthanhthao01/Amazon-Project/blob/main/Supply%20Chain.png?raw=true)


# Recommendations:

Based on the insights and findings above, we would recommend the stakeholder team to consider the following: 

* **Address order fulfillment delays:** With over 39,000 orders from April and May still incomplete by the end of Q2, a real-time tracking and escalation system is needed to reduce delivery delays and improve customer satisfaction.

  
* **Secure inventory for top-performing products:** T-shirts and shirts in sizes S to 3XL are in high demand across India, especially in Karnataka, Andhra Pradesh, and Tamil Nadu. Ensuring stock availability for these SKUs should be a priority to meet customer expectations and sustain revenue.

  
* **Scale expedited shipping in high-demand states:** Expedited shipping volumes were 2–3 times higher than Standard and are managed by Amazon directly. Expanding this service, particularly in key states, will help maintain delivery speed and success rates.


* **Address data discrepancies in order processing:** The gap between total orders (120K) and total quantity sold (116K) suggests that cancellations are not consistently handled in reporting, particularly when canceled orders reset quantities to zero. This highlights the need to improve how cancellations are logged and reported to ensure accurate performance tracking.
  


# Assumptions and Caveats:

Throughout the analysis, multiple assumptions were made to manage challenges with the data. These assumptions and caveats are noted below:

* **Assumption 1:** Several irrelevant or null-heavy columns (e.g., New, currency, ship_city) were excluded from analysis to reduce noise.

* **Assumption 2:** Amount column had ~4.7% missing values, which were imputed using averages based on fulfillment type, sales channel, service level, and product attributes.

* **Assumption 3:** To simplify analysis of order fulfillment outcomes, a new column named Grouped Status was created by grouping multiple detailed status values into four main categories:
  - Success: Includes orders marked as "Shipped - Delivered to Buyer".
  - Fail: Covers orders that were "Cancelled", "Shipped - Damaged", "Shipped - Lost in Transit", or "Shipped - Rejected by Buyer".
  - Return: Includes "Shipped - Returned to Seller" and "Shipped - Returning to Seller".
  - Ongoing: Captures all remaining statuses, representing orders that are still in progress or awaiting final outcome.

* **Caveat:** Duplicate entries were not removed due to the absence of unique order-item identifiers, potentially leading to slight overcounting in product-level summaries.
