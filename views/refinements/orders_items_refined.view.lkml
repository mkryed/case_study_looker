include: "/views/raw/*.view"

view: +order_items {

  dimension_group: created {
    type: time
    view_label: "_PoP"
    timeframes: [
      raw,
      time,
      hour_of_day,
      date,
      day_of_week,
      day_of_week_index,
      day_of_month,
      day_of_year,
      week,
      week_of_year,
      month,
      month_name,
      month_num,
      quarter,
      year
    ]
    sql: ${TABLE}.created_at ;;
    convert_tz: no
  }


#(Method 1a) you may also wish to create MTD and YTD filters in LookML

  dimension: wtd_only {
    group_label: "To-Date Filters"
    label: "WTD"
    view_label: "_PoP"
    type: yesno
    sql:  (EXTRACT(DOW FROM ${created_raw}) < EXTRACT(DOW FROM GETDATE())
                OR
            (EXTRACT(DOW FROM ${created_raw}) = EXTRACT(DOW FROM GETDATE()) AND
            EXTRACT(HOUR FROM ${created_raw}) < EXTRACT(HOUR FROM GETDATE()))
                OR
            (EXTRACT(DOW FROM ${created_raw}) = EXTRACT(DOW FROM GETDATE()) AND
            EXTRACT(HOUR FROM ${created_raw}) <= EXTRACT(HOUR FROM GETDATE()) AND
            EXTRACT(MINUTE FROM ${created_raw}) < EXTRACT(MINUTE FROM GETDATE())))  ;;
  }

  dimension: mtd_only {
    group_label: "To-Date Filters"
    label: "MTD"
    view_label: "_PoP"
    type: yesno
    sql:  (EXTRACT(DAY FROM ${created_raw}) < EXTRACT(DAY FROM GETDATE())
                OR
            (EXTRACT(DAY FROM ${created_raw}) = EXTRACT(DAY FROM GETDATE()) AND
            EXTRACT(HOUR FROM ${created_raw}) < EXTRACT(HOUR FROM GETDATE()))
                OR
            (EXTRACT(DAY FROM ${created_raw}) = EXTRACT(DAY FROM GETDATE()) AND
            EXTRACT(HOUR FROM ${created_raw}) <= EXTRACT(HOUR FROM GETDATE()) AND
            EXTRACT(MINUTE FROM ${created_raw}) < EXTRACT(MINUTE FROM GETDATE())))  ;;
  }

  dimension: ytd_only {
    group_label: "To-Date Filters"
    label: "YTD"
    view_label: "_PoP"
    type: yesno
    sql:  (EXTRACT(DOY FROM ${created_raw}) < EXTRACT(DOY FROM GETDATE())
                OR
            (EXTRACT(DOY FROM ${created_raw}) = EXTRACT(DOY FROM GETDATE()) AND
            EXTRACT(HOUR FROM ${created_raw}) < EXTRACT(HOUR FROM GETDATE()))
                OR
            (EXTRACT(DOY FROM ${created_raw}) = EXTRACT(DOY FROM GETDATE()) AND
            EXTRACT(HOUR FROM ${created_raw}) <= EXTRACT(HOUR FROM GETDATE()) AND
            EXTRACT(MINUTE FROM ${created_raw}) < EXTRACT(MINUTE FROM GETDATE())))  ;;
  }


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
    value_format_name: millions
  }

   measure: total_gross_margin {
    description: "Total difference between the total revenue from completed sales and the
    cost of the goods that were sold"
    type:number
    sql: ${total_gross_revenue}-${inventory_items.total_cost_sold_items} ;;
    value_format_name: usd
    drill_fields: [products.brand,products.category,products.count,order_items.total_gross_margin]
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
    sql: ${total_gross_margin}/NULLIF(${total_gross_revenue},0) ;;
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
    type: count_distinct
    sql: ${order_id} ;;
    drill_fields: [created_date,count]
  }

  measure: count {
    type: count
    drill_fields: [order_items.order_id,order_items.created_date,products.id,order_items.count]
  }
}
