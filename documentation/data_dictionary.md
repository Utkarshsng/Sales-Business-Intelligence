# Project 1 Data Dictionary

## customers
- customer_id: Unique customer identifier.
- customer_name: Synthetic customer name.
- gender: Customer gender.
- age: Customer age.
- city: Customer city.
- state: Customer state.
- customer_segment: Consumer, Corporate, or Small Business.
- acquisition_date: Customer acquisition date.

## products
- product_id: Unique product identifier.
- product_name: Synthetic product name.
- category: Main product category.
- subcategory: Product subcategory.
- brand: Synthetic brand.
- unit_cost: Cost to the business.
- selling_price: Standard selling price.

## stores
- store_id: Unique store identifier.
- store_name: Synthetic store/business hub name.
- city: Store city.
- state: Store state.
- region: Business region.
- channel: Retail, Online, or Partner.

## orders
- order_id: Unique transaction identifier.
- order_date: Transaction date.
- customer_id: Customer foreign key.
- product_id: Product foreign key.
- store_id: Store foreign key.
- quantity: Units purchased.
- unit_price: Actual transaction unit price.
- discount_pct: Discount applied.
- sales_amount: Quantity × Unit Price × (1 - Discount).
- cost_amount: Quantity × Unit Cost.
- profit: Sales Amount - Cost Amount - Shipping Cost.
- return_flag: Whether the order was returned.
- payment_method: Payment method.
- order_status: Completed, Cancelled, Pending, or Returned.
- shipping_cost: Shipping expense.

## date
Calendar dimension used for time intelligence and reporting.
