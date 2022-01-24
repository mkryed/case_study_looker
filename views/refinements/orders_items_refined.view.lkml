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


  measure: Percentage_gross_margin {
    group_label: "Percentage"
    description: "Total Gross Margin Amount / Total Gross Revenue"
    type: number
    sql: ${total_gross_margin}/NULLIF(${total_gross_revenue},0) ;;
    value_format_name: percent_1

  }

  measure: number_of_items_returned {
    group_label: "Count"
    description: "Number of Returned Items"
    type: count
    filters: [status: "Returned"]
  }

  measure: percentage_item_return {
    group_label: "Percentage"
    description: "Number of Items Returned / total number of items sold"
    type: number
    sql: ${number_of_items_returned}/${count} ;;
    value_format_name: percent_1
  }

  measure: number_of_customers_with_return{
    group_label: "Count"
    description: "Number of users who have returned an item at some point"
    type: count_distinct
    sql: ${user_id} ;;
    filters: [status: "Returned"]
  }

  measure: percentage_of_user_with_return {
    group_label: "Percentage"
    description: "Number of Customer Returning Items / total number of customers"
    type: number
    sql: ${number_of_customers_with_return}/${users.count_users} ;;
    value_format_name: percent_1
  }


  measure: average_spend_per_customer {
    group_label: "Average"
    description: "Total Sale Price / total number of customers"
    type: number
    sql: ${total_sale_price}/${users.count_users};;
    value_format_name: usd
    drill_fields: [users.revenue_source_comparison_set*]
  }

  measure: revenue_from_new_customer {
    description:"Revenue generated from customers who have recently joined withing the last 90 days"
    type: sum
    sql: ${sale_price} ;;
    filters: [status: "Complete,Processing,Shipped",users.created_date: "90 days"]
    value_format_name: usd
  }

  measure: revenue_from_old_customer{
    description: "Revenue generated from long-term customers"
    type: sum
    sql: ${sale_price} ;;
    filters: [status: "Complete,Processing,Shipped",users.created_date: "before 90 days ago"]
    value_format_name: usd
  }

  measure: total_order_counts {
    group_label: "Count"
    label: "Number of Orders Placed"
    type: count_distinct
    sql: ${order_id} ;;
    drill_fields: [created_date,count]
  }

  measure: count {
    group_label: "Count"
    label: "Number of All Order Items"
    type: count
    drill_fields: [order_items.order_id,order_items.created_date,products.id,order_items.count]
  }

  measure: count_of_sold_order_items {
    group_label: "Count"
    label: "Number of Sold Order Items Only"
    filters: [status: "Complete,Processing,Shipped"]
    type: count
    drill_fields: [order_items.order_id,order_items.created_date,products.id,order_items.count]
  }


}
