view: dt_order_repurchase_facts {
  derived_table: {
    sql: SELECT ROW_NUMBER() OVER(ORDER BY ordered) as RN,*

                  FROM

                      ( SELECT

                        order_items.user_id as user_id,

                        order_items.id AS order_id,

                        p.category as category,

                        MIN(order_items.created_at) OVER(PARTITION BY order_items.user_id) as first_ordered_at,

                        MAX(order_items.created_at) OVER(PARTITION BY order_items.user_id) as last_ordered_at,

                        order_items.created_at as ordered,

                        COUNT(order_items.id) OVER(partition by order_items.user_id) as lifetime_orders,

                        ROW_NUMBER() OVER(PARTITION BY order_items.user_id ORDER BY order_items.created_at) as order_sequence_number,

                        LEAD(order_items.created_at) OVER(partition by order_items.user_id ORDER BY order_items.created_at) as second_created_at,

                        DATEDIFF(DAY,CAST(order_items.created_at as date),CAST(LEAD(order_items.created_at) over(partition by order_items.user_id ORDER BY order_items.created_at) AS date)) as repurchase_gap,

                        DATEDIFF(DAY, CURRENT_DATE,CAST(MIN(order_items.created_at) OVER(partition by order_items.user_id) as DATE)) as days_since_first_order,

                        DATEDIFF(DAY, CURRENT_DATE,CAST(MAX(order_items.created_at) OVER(partition by order_items.user_id) as DATE)) as days_since_latest_order,

                        SUM(order_items.sale_price)  as lifetime_revenue

                      FROM  order_items

                      JOIN inventory_items ii ON order_items.inventory_item_id=ii.id

                      JOIN products p on ii.product_id = p.id

                      WHERE

                      {% condition product_category %} p.category {% endcondition %}

                      GROUP BY 1,2,3,6

                      )
             ;;
  }

  ##### Filter ######


  filter: product_category {
    suggest_dimension: category
  }


  measure: count {
    type: count
    hidden: yes
    drill_fields: [detail*]
  }

  dimension: rn {
    type: number
    sql: ${TABLE}."RN" ;;
    primary_key: yes
    hidden: yes
    }

  dimension: user_id {
    type: number
    hidden: yes
    sql: ${TABLE}."USER_ID" ;;
  }

  dimension: order_id {
    type: number
    sql: ${TABLE}."ORDER_ID" ;;

  }

  dimension: category {
    type: string
    sql: ${TABLE}."CATEGORY" ;;
  }


  dimension_group: first_ordered_at {
    type: time
    sql: ${TABLE}."FIRST_ORDERED_AT" ;;
    timeframes: [date,month,month_name,year]
    hidden: yes
  }

  dimension_group: last_ordered_at {
    type: time
    sql: ${TABLE}."LAST_ORDERED_AT" ;;
    timeframes: [date,month,month_name,year]
    hidden: yes
  }

  dimension: ordered {
    type: string
    sql: ${TABLE}."ORDERED" ;;
    hidden: yes
  }

  dimension: lifetime_orders {
    type: number
    sql: ${TABLE}."LIFETIME_ORDERS" ;;
    hidden: yes

  }

  measure: lifetime_orders_measure {
    type: sum_distinct
    sql: ${lifetime_orders} ;;
    sql_distinct_key: ${user_id} ;;
    hidden: yes
  }



  dimension: order_sequence_number {
    type: number
    sql: ${TABLE}."ORDER_SEQUENCE_NUMBER" ;;
  }

  dimension_group: second_created_at {
    type: time
    sql: ${TABLE}."SECOND_CREATED_AT" ;;
    hidden: yes
  }

  dimension: repurchase_gap {
    type: number
    sql: ${TABLE}."REPURCHASE_GAP" ;;
  }

  dimension: days_since_first_order {
    type: number
    sql: ${TABLE}."DAYS_SINCE_FIRST_ORDER" ;;

  }

  dimension: days_since_latest_order {
    type: number
    sql: ${TABLE}."DAYS_SINCE_LATEST_ORDER" ;;

  }

  ###### Dimension created #######

  dimension: repurchase_tier {
    type: tier
    tiers: [30,60,90,120,150,180]
    style: integer
    sql: ${repurchase_gap} ;;
  }

  # #dimension: days_since_first_order_tier {
  #   type: tier
  #   tiers: [30,60,90,120,150,180]
  #   style: integer
  #   sql: ${days_since_first_order} ;;
  # }

  dimension: repurchase_made {
    type: yesno
    hidden: yes
    sql: ${repurchase_gap} IS NOT NULL ;;
  }



  ##>> These dimension will check if a user's 2nd purchase was within certain time intervals ##

  dimension: repurchase_30  {type:yesno sql:${repurchase_gap} <=30 AND  ${order_sequence_number}=2;; hidden:yes}

  dimension: repurchase_60  {type:yesno sql:${repurchase_gap} <=60 AND  ${order_sequence_number}=2;; hidden:yes}

  dimension: repurchase_90  {type:yesno sql:${repurchase_gap} <=90 AND  ${order_sequence_number}=2;; hidden:yes}

  dimension: repurchase_120 {type:yesno sql:${repurchase_gap} <=120 AND ${order_sequence_number}=2;; hidden:yes}

  dimension: repurchase_150 {type:yesno sql:${repurchase_gap} <=150 AND ${order_sequence_number}=2;; hidden:yes}

  dimension: repurchase_180 {type:yesno sql:${repurchase_gap} <=180 AND ${order_sequence_number}=2;; hidden:yes}



  ##### MEASURE ######


  measure: count_repurchases {
    description: "Count of unique users who made more than 1 purchase"
    type: count_distinct
    drill_fields: [detail*]
    sql: ${user_id} ;;
    filters: [repurchase_made: "Yes",order_sequence_number: "2"]
  }

  measure: average_repurchase_gap {
    description: "The average time in days it takes for users to make a subsequent purchase"
    drill_fields: [detail*]
    type: average_distinct
    sql: ${repurchase_gap} ;;
    sql_distinct_key: ${order_id} ;;
    filters: [order_sequence_number: "2"]
  }


  measure: count_customers {

    drill_fields: [detail*]

    type: count_distinct

    sql: ${user_id} ;;

  }

  measure: count_orders {

    drill_fields: [detail*]

    type: count_distinct

    sql: ${order_id} ;;

  }

  # measure: percent_of_customers {

  #   drill_fields: [detail*]

  #   type: percent_of_total

  #   sql: ${count_customers} ;;

  # }

  ##>> Count of repurchases by users in N days since first purchase##

  measure: count_repurchases_first_30_days {
    label: "1m"
    group_label: "Count Repurchases"
    type: count_distinct
    sql: ${user_id} ;;
    drill_fields: [detail*]
    filters: [repurchase_30: "Yes"]
  }

  measure: count_repurchases_first_60_days {
    label: "2m"
    group_label: "Count Repurchases"
    type: count_distinct
    sql: ${user_id} ;;
    drill_fields: [detail*]
    filters: [repurchase_60: "Yes"]
  }

  measure: count_repurchases_first_90_days {
    label: "3m"
    group_label: "Count Repurchases"
    type: count_distinct
    sql: ${user_id} ;;
    drill_fields: [detail*]
    filters: [repurchase_90: "Yes"]
  }

  measure: count_repurchases_first_120_days {
    label: "4m"
    group_label: "Count Repurchases"
    type: count_distinct
    sql: ${user_id} ;;
    drill_fields: [detail*]
    filters: [repurchase_120:"Yes"]
  }

  measure: count_repurchases_first_150_days {
    label: "5m"
    group_label: "Count Repurchases"
    type: count_distinct
    sql: ${user_id} ;;
    drill_fields: [detail*]
    filters: [repurchase_150: "Yes"]
  }

  measure: count_repurchases_first_180_days {
    label: "6m"
    group_label: "Count Repurchases"
    type: count_distinct
    sql: ${user_id} ;;
    drill_fields: [detail*]
    filters: [repurchase_180: "Yes"]
  }


  ### Repurchase Rates ###
  measure: repurchase_rate {
    group_label: "Repurchase Rates"
    type: number
    drill_fields: [detail*]
    value_format_name: percent_1
    sql: 1.0*${count_repurchases}/NULLIF(${count_customers},0) ;;
  }

  measure: repurchase_rate_30 {

    label: "1m"

    group_label: "Repurchase Rates"

    type: number

    drill_fields: [detail*]

    value_format_name: percent_1

    sql: 1.0*${count_repurchases_first_30_days}/nullif(${count_customers},0) ;;

  }

  measure: repurchase_rate_60 {

    label: "2m"

    group_label: "Repurchase Rates"

    type: number

    drill_fields: [detail*]

    value_format_name: percent_1

    sql: 1.0*${count_repurchases_first_60_days}/nullif(${count_customers},0) ;;

  }

  measure: repurchase_rate_90 {

    label: "3m"

    group_label: "Repurchase Rates"

    type: number

    drill_fields: [detail*]

    value_format_name: percent_1

    sql: 1.0*${count_repurchases_first_90_days}/nullif(${count_customers},0) ;;

  }

  measure: repurchase_rate_120 {

    label: "4m"

    group_label: "Repurchase Rates"

    type: number

    drill_fields: [detail*]

    value_format_name: percent_1

    sql: 1.0*${count_repurchases_first_120_days}/nullif(${count_customers},0) ;;

  }

  measure: repurchase_rate_150 {

    label: "5m"

    group_label: "Repurchase Rates"

    type: number

    drill_fields: [detail*]

    value_format_name: percent_1

    sql: 1.0*${count_repurchases_first_150_days}/nullif(${count_customers},0) ;;

  }

  measure: repurchase_rate_180 {

    label: "6m"

    group_label: "Repurchase Rates"

    type: number

    drill_fields: [detail*]

    value_format_name: percent_1

    sql: 1.0*${count_repurchases_first_180_days}/nullif(${count_customers},0) ;;

  }


  set: detail {
    fields: [
      rn,
      user_id,
      order_id,
      category,
      first_ordered_at_date,
      last_ordered_at_date,
      ordered,
      lifetime_orders,
      order_sequence_number,
      days_since_first_order,
      days_since_latest_order
    ]
  }
}
