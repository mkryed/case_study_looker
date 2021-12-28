include: "/views/raw/*.view"

view: +order_items {

  measure: total_sale_price {
    description: "Total Sales from items sold"
    type: sum
    sql: ${sale_price} ;;
    value_format_name: usd
  }

  measure: average_sale_price {
    description: "Average sale price of items sold"
    type: average
    sql: ${sale_price} ;;
    value_format_name: usd
  }

  measure: total_gross_revenue {
    description: "Total revenue from completed sales (cancelled and returned orders excluded)"
    type: sum
    sql: ${sale_price};;
    filters: [status: "Complete,Processing,Shipped"]
    value_format_name: usd
  }

  measure: total_gross_margin {
    description: "Total difference between the total revenue from completed sales and the
    cost of the goods that were sold"
    type:number
    sql: ${total_gross_revenue}-${inventory_items.total_cost_sold_items} ;;
    value_format_name: usd
  }

  measure: average_gross_margin {
    description: "Average difference between the total revenue from completed sales and
    the cost of the goods that were sold"
    type: number
    sql: ${total_gross_margin}/${count} ;;
    value_format_name: usd
  }

  measure: gross_margin_percentage {
    description: "Total Gross Margin Amount / Total Gross Revenue"
    type: number
    sql: ${total_gross_margin}/${total_gross_revenue} ;;
    value_format_name: percent_1

  }

  measure: number_of_items_returned {
    description: "Number of items that were returned by dissatisfied customers"
    type: count
    filters: [status: "Returned"]
  }

  measure: item_return_rate {
    description: "Number of Items Returned / total number of items sold"
    type: number
    sql: ${number_of_items_returned}/${count} ;;
    value_format_name: percent_1
  }

  measure: number_of_customers_returning_items {
    description: "Number of users who have returned an item at some point"
    type: count_distinct
    sql: ${user_id} ;;
    filters: [status: "Returned"]
  }

  measure: percentage_of_user_with_returns {
    description: "Number of Customer Returning Items / total number of customers"
    type: number
    sql: ${number_of_customers_returning_items}/${unique_customer_count} ;;
    value_format_name: percent_1
  }

  measure: unique_customer_count {
    type: count_distinct
    sql: ${user_id} ;;
  }

  measure: average_spend_per_customer {
    description: "Total Sale Price / total number of customers"
    type: number
    sql: ${total_sale_price}/${unique_customer_count};;
    value_format_name: usd
  }
}
