view: order_patterns_and_frequnecy {
  derived_table: {
    sql: SELECT

                                          order_items.user_id as user_id,


                                          order_items.order_id as order_id,

                                          LEAD(order_items.order_id) OVER(partition by order_items.user_id ORDER BY order_items.created_at) as second_order_id,

                                          ROW_NUMBER() OVER(PARTITION BY order_items.user_id ORDER BY order_items.created_at) as order_sequence_number,

                                          MIN(order_items.created_at) OVER(PARTITION BY order_items.user_id) as first_ordered_at,


                                          order_items.created_at as ordered,

                                          LEAD(order_items.created_at) OVER(partition by order_items.user_id ORDER BY order_items.created_at) as second_created_at,


                                          DATEDIFF(DAY,CAST(order_items.created_at as date),CAST(LEAD(order_items.created_at) over(partition by order_items.user_id ORDER BY order_items.created_at) AS date)) days_between_orders,

                                          DATEDIFF(DAY, CURRENT_DATE,CAST(MIN(order_items.created_at) OVER(partition by order_items.user_id) as DATE)) as days_since_first_order,

                                          DATEDIFF(DAY, CURRENT_DATE,CAST(MAX(order_items.created_at) OVER(partition by order_items.user_id) as DATE)) as days_since_latest_order


                                        FROM  order_items


                                        GROUP BY 1,2,6
                   ;;
  }


  dimension: user_id {
    type: number
    sql: ${TABLE}."USER_ID" ;;
    hidden: yes
  }

  dimension: order_id {
    type: number
    sql: ${TABLE}."ORDER_ID" ;;
    primary_key: yes
  }

  dimension: second_order_id {
    type: number
    sql: ${TABLE}."SECOND_ORDER_ID" ;;
    hidden: yes
  }

  dimension: order_sequence_number {
    description: "The order in which a customer placed orders over their lifetime as
    a fashion.ly customer"
    type: number
    sql: ${TABLE}."ORDER_SEQUENCE_NUMBER" ;;
  }

  dimension_group: first_ordered_at {
    type: time
    sql: ${TABLE}."FIRST_ORDERED_AT" ;;
    hidden: yes
  }

  dimension_group: ordered {
    type: time
    sql: ${TABLE}."ORDERED" ;;
    hidden: yes
  }

  dimension_group: second_created_at {
    type: time
    sql: ${TABLE}."SECOND_CREATED_AT" ;;
    hidden: yes
  }

  dimension: days_between_orders {
    description: "The number of days between one order and the next order"
    type: number
    sql: ${TABLE}."DAYS_BETWEEN_ORDERS" ;;
  }

  dimension: days_since_first_order {
    type: number
    sql: ${TABLE}."DAYS_SINCE_FIRST_ORDER" ;;
    hidden: yes
  }

  dimension: days_since_latest_order {
    type: number
    sql: ${TABLE}."DAYS_SINCE_LATEST_ORDER" ;;
    hidden: yes
  }

  #Created Dimension

  dimension: is_first_purchase {
    description: "Indicator for whether a purchase is a customer’s first purchase or
    not"
    type: yesno
    sql: ${order_sequence_number}=1 ;;
  }

  dimension: has_subsequent_order {
    description: "Indicator for whether or not a customer placed a subsequent order
    on the website"
    type: yesno
    sql: ${order_id}!=${second_order_id} AND ${ordered_date}=${second_created_at_date} ;;
  }

  dimension: has_purchase_within_60days {
    type: yesno
    sql: ${days_between_orders}<60 AND ${second_created_at_date} IS NOT NULL ;;
  }



  # Created Measure

  measure: average_days_between_orders {
    description: "The average number of days between orders placed"
    type: average
    sql: ${days_between_orders} ;;
  }

  measure: count_of_user_with_60_days_purchase_rate {
    type: count_distinct
    sql: ${user_id} ;;
    filters: [has_purchase_within_60days: "Yes"]

  }

}
