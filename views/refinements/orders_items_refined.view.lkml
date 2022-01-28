include: "/views/raw/*.view"

view: +order_items {


  measure: total_sale_price {
    group_label: "Sum"
    description: "Total Sales from items sold"
    type: sum
    sql: ${sale_price} ;;
    value_format_name: usd
  }

  measure: average_sale_price {
    group_label: "Average"
    description: "Average sale price of items sold"
    type: average
    sql: ${sale_price} ;;
    value_format_name: usd
  }

  measure: total_gross_revenue {
    group_label: "Sum"
    description: "Total revenue from completed sales (cancelled and returned orders excluded)"
    type: sum
    sql: ${sale_price};;
    filters: [status: "Complete,Processing,Shipped"]
    value_format_name: millions
  }

  measure: average_total_gross_revenue {
    group_label: "Average"
    description: "Average Total revenue from completed sales (cancelled and returned orders excluded)"
    type: average
    sql: ${sale_price};;
    filters: [status: "Complete,Processing,Shipped"]
    value_format_name: usd
  }


   measure: total_gross_margin {
    group_label: "Sum"
    description: "Total difference between the total revenue from completed sales and the
    cost of the goods that were sold"
    type:number
    sql: ${total_gross_revenue}-${inventory_items.total_cost_sold_items} ;;
    value_format_name: usd
    drill_fields: [products.brand,products.category,products.count,order_items.total_gross_margin]
  }

  measure: average_gross_margin {
    group_label: "Average"
    description: "Average difference between the total revenue from completed sales and
    the cost of the goods that were sold"
    type: number
    sql: ${total_gross_margin}/${count_of_sold_order_items} ;;
    value_format_name: usd
  }


  measure: percentage_gross_margin {
    group_label: "Percentage"
    description: "Total Gross Margin Amount / Total Gross Revenue"
    type: number
    sql: ${total_gross_margin}/NULLIF(${total_gross_revenue},0) ;;
    value_format_name: percent_1

  }

  measure: count_items_returned {
    label: "Number of items returned"
    group_label: "Count"
    description: "Number of Returned Items"
    type: count
    filters: [status: "Returned"]
  }

  measure: percentage_item_return {
    group_label: "Percentage"
    description: "Number of Items Returned / total number of items sold"
    type: number
    sql: ${count_items_returned}/${count_total} ;;
    value_format_name: percent_1
  }

  measure: count_customers_with_return{
    group_label: "Count"
    label: "Number of customers with return"
    description: "Number of users who have returned an item at some point"
    type: count_distinct
    sql: ${user_id} ;;
    filters: [status: "Returned"]
  }

  measure: percentage_of_user_with_return {
    group_label: "Percentage"
    description: "Number of customer returning items / total number of customers"
    type: number
    sql: ${count_customers_with_return}/${users.count_users} ;;
    value_format_name: percent_1
  }

  measure: average_spend_per_customer {
    group_label: "Average"
    description: "Total sale price / total number of customers"
    type: number
    sql: ${total_sale_price}/${users.count_users};;
    value_format_name: usd
    drill_fields: [users.revenue_source_comparison_set*]
  }

  measure: total_revenue_from_new_customer {
    group_label: "Sum"
    description:"Revenue generated from customers who have recently joined withing the last 90 days"
    type: sum
    sql: ${sale_price} ;;
    filters: [status: "Complete,Processing,Shipped",users.created_date: "90 days"]
    value_format_name: usd
  }

  measure: total_revenue_from_old_customer{
    group_label: "Sum"
    description: "Revenue generated from long-term customers"
    type: sum
    sql: ${sale_price} ;;
    filters: [status: "Complete,Processing,Shipped",users.created_date: "before 90 days ago"]
    value_format_name: usd
  }

  measure: count_total_orders {
    group_label: "Count"
    label: "Number of orders placed"
    type: count_distinct
    sql: ${order_id} ;;
    }

    measure: count_customer_who_ordered{
      group_label: "Count"
      label: "Number of Customer who order"
      type: count_distinct
      sql: ${user_id} ;;
    }

  measure: count_total {
    group_label: "Count"
    label: "Number of all order items"
    type: count
    drill_fields: [order_items.order_id,order_items.created_date,products.id,order_items.count]
  }

  measure: count_of_sold_order_items {
    group_label: "Count"
    label: "Number of sold order items only"
    filters: [status: "Complete,Processing,Shipped"]
    type: count
    drill_fields: [order_items.order_id,order_items.created_date,products.id,order_items.count]
  }

## For customer Cohort Analysis

  dimension_group: since_signup {
    type: duration
    sql_start: ${users.created_raw} ;;
    sql_end: ${order_items.created_raw} ;;
  }

  dimension: months_since_signup_tier {
    description: "The number of months since a customer has signed up on the
website"
    group_label: "Tier"
    type: tier
    tiers: [1,2,3,6,12]
    style: integer
    sql: ${months_since_signup} ;;
  }

  dimension: days_since_signup_tier {
    description: "The number of days since a customer has signed up on the
website"
    group_label: "Tier"
    type: tier
    style: integer
    tiers: [10,50,100,200,350]
    sql: ${days_since_signup} ;;
  }

  measure: avg_months_since_signup {
    group_label: "Average"
    type: average
    sql: ${months_since_signup} ;;
    description: "Average number of months between a customer initially
registering on the website and now"
  }

  measure: avg_days_since_signup {
    group_label: "Average"
    type: average
    sql: ${days_since_signup} ;;
    description: "Average number of days between a customer initially
registering on the website and now"
  }

}
