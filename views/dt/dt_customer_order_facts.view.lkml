# If necessary, uncomment the line below to include explore_source.

# include: "order_items.explore.lkml"

view: dt_customer_order_facts {
  derived_table: {
    explore_source: order_items {
      column: created {field:order_items.created_date}
      column: order_id {}
      column: user_id { field: users.id }
      derived_column: rank{
        sql: dense_rank() OVER (PARTITION BY user_id ORDER BY order_id) ;;
      }
      derived_column: last_buy_at {
        sql: lag(created) OVER (PARTITION BY user_id ORDER BY order_id) ;;
      }

      filters: {
        field: order_items.created_date
        value: "NOT NULL"
      }
    }
  }
  dimension_group: created{
    type: time
    timeframes: [
      date,
      week,
      month,
      quarter,
      year
    ]

  }

  dimension_group:last_buy_at  {
    type: time
    timeframes: [
      date,
      week,
      month,
      quarter,
      year
    ]

  }

  dimension: days_between_orders {
    type: duration_day
    sql_start: ${last_buy_at_date} ;;
    sql_end: ${created_date} ;;
  }


  dimension: has_placed_subsequent_order {
    type: yesno
    sql: ${days_between_orders}=0 ;;
  }

  dimension: is_first_purchase {
    type: yesno
    sql: ${rank}=1 ;;
  }

  dimension: order_id {
    type: number
  }

  dimension: rank {
    type: number
  }

  dimension: user_id {
    type: number
    primary_key: yes
  }

  #measure
  measure: avg_days_between_orders {
    type: average
    sql: ${days_between_orders} ;;
  }

  measure: total_customer_purchased_within_60_days {
    type: count_distinct
    sql: ${user_id} ;;
    filters: [days_between_orders: ">=0 AND <60", rank: ">1"]
  }

  measure:user_count {
    type: count_distinct
    sql: ${user_id} ;;
  }
}
