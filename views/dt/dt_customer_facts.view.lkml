view: dt_customer_facts {
  derived_table: {

    sql: select b.user_id as user_id,
      MIN(b.created_at) as First_order,
      MAX(b.created_at) as Latest_order,
      count(distinct b.order_id) as Total_orders,
      sum(b.sale_price) as Total_revenue
      from order_items b
      group by 1
       ;;
  }

  measure: count {
    type: count
    label: "count"
    drill_fields: [detail*]
    hidden: yes
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}."USER_ID" ;;
    primary_key: yes
  }

  dimension_group: first_order {
    description: "The date in which a customer placed his or her first order on the
    fashion.ly website"
    type: time
    sql: ${TABLE}."FIRST_ORDER" ;;
  }

  dimension_group: latest_order {
    description: "The date in which a customer placed his or her most recent order
    on the fashion.ly website"
    type: time
    sql: ${TABLE}."LATEST_ORDER" ;;
  }

  dimension: total_orders {
    type: number
    sql: IFNULL(${TABLE}."TOTAL_ORDERS" ,0);;
    hidden: no
  }

  dimension: total_revenue {
    type: number
    sql: IFNULL(${TABLE}."TOTAL_REVENUE",0) ;;
    hidden: yes
    value_format_name: usd
  }


  dimension: customer_lifetime_orders_tier {
    description: "The total number of orders that a customer has placed since first
    using the website."
    type: tier
    tiers: [1,2,3,6,10]
    sql: NULLIF(${total_orders},0) ;;
    style: integer
  }

  dimension: customer_lifetime_revenue_tier {
    description: "The total amount of revenue brought in from an individual
    customer over the course of their patronage"
    type: tier
    tiers: [5,20,50,100,500,1000]
    style: integer
    sql: ${total_revenue} ;;
    value_format_name: usd
  }

  dimension: days_since_latest_order{
    description: "The number of days since a customer placed his or her most
    recent order on the website"
    type: duration_day
    sql_start: ${latest_order_raw} ;;
    sql_end:  CURRENT_DATE ;;
  }

  dimension: is_active {
    description: "Identifies whether a customer is active or not (has purchased from
    the website within the last 90 days)"
    type: yesno
    sql: ${days_since_latest_order} <= 90 ;;
  }

  dimension: is_repeat_customer {
    description: "Identifies whether a customer was a repeat customer or not"
    type: yesno
    sql: ${dt_customer_facts.total_orders} != '1' AND ${dt_customer_facts.total_orders} IS NOT NULL ;;
  }

#measure
  measure: total_lifetime_revenue {
    description: "The total amount of revenue brought in over the course of
    customers’ lifetimes."
    type: sum
    sql: ${total_revenue} ;;
    value_format_name: usd
    drill_fields: [products.id,order_items.count,products.retail_price,products.cost,order_items.sale_price]
  }

  measure: total_lifetime_orders {
    description: "The total number of orders placed over the course of customers’
    lifetimes."
    type: sum
    sql: ${total_orders} ;;
  }

  measure: average_lifetime_orders {
    description: "The average number of orders that a customer places over the
    course of their lifetime as a customer."
    type: average
    sql: ${total_orders} ;;
  }

  measure: average_lifetime_revenue {
    description: "The average amount of revenue that a customer brings in over the
    course of their lifetime as a customer."
    type: average
    sql: ${total_revenue} ;;
    value_format_name: usd
  }

  measure: average_days_since_latest_order {
    description: "The average number of days since customers have placed their
    most recent orders on the website"
    type: average
    sql: ${days_since_latest_order} ;;
  }


  set: detail {
    fields: [
      total_orders,
      first_order_time,
      latest_order_time,
      total_lifetime_orders,
      total_lifetime_revenue
    ]
  }
}
