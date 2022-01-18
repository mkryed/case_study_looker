view:customer_order_facts{
  derived_table: {
    sql: select user_id as user_id,
      order_id as order_id,
      created_at,
      dense_rank() over (partition by user_id order by created_at ASC) as rank,
      lead(created_at) over (partition by user_id order by created_at ASC) as last_buy_at
      from order_items order by 1,3
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
    hidden: yes
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}."USER_ID" ;;
    primary_key: yes
  }

  dimension: order_id {
    type: number
    sql: ${TABLE}."ORDER_ID" ;;
  }

  dimension_group: created_at {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."CREATED_AT" ;;
  }

  dimension: rank {
    type: number
    sql: ${TABLE}."RANK" ;;
  }

  dimension_group: last_buy_at {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."LAST_BUY_AT" ;;
  }

#Measure

  # measure: is_first_purchase {
  #   type: yesno
  #   sql: ${rank}=1 ;;
  # }

  # measure: has_subsequent_order {
  #   type: yesno
  #   sql: ${last_buy_at_raw}-${created_at_raw}=0 ;;
  # }

  set: detail {
    fields: [user_id, order_id, created_at_time, rank, last_buy_at_time]
  }
}
