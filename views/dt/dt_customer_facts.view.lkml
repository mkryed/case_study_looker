view: dt_customer_facts {
  derived_table: {
    sql: select a.id as user_id,
      MIN(b.created_at) as First_order,
      MAX(b.created_at) as Latest_order,
      count(distinct b.order_id) as Total_orders,
      sum(sale_price) as Total_revenue,
      dense_rank() OVER (order by count(distinct b.order_id) DESC) as rank_by_number_orders
      from users a
      JOIN order_items b
      ON a.id=b.user_id
      group by a.id
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}."USER_ID" ;;
    primary_key: yes
    }

  dimension_group: first_order {
    type: time
    sql: ${TABLE}."FIRST_ORDER" ;;
  }

  dimension_group: latest_order {
    type: time
    sql: ${TABLE}."LATEST_ORDER" ;;
  }

  dimension: total_orders {
    type: number
    sql: ${TABLE}."TOTAL_ORDERS" ;;
    hidden: yes
      }

  dimension: total_revenue {
    type: number
    sql: ${TABLE}."TOTAL_REVENUE" ;;
    hidden: yes
    value_format_name: usd
      }

  dimension: rank_by_number_orders{
    type: number
    sql: ${TABLE}."RANK_BY_NUMBER_ORDERS" ;;
  }

  dimension: customer_lifetime_orders {
    type: string
    allow_fill: no
    case: {
      when: {
        sql: dt_customer_facts.total_orders =1 ;;
        label: "1 Order"
        }
      when: {
        sql: dt_customer_facts.total_orders =2 ;;
        label: "2 Orders"
      }
      when: {
        sql: dt_customer_facts.total_orders >=3 and dt_customer_facts.total_orders <=5 ;;
        label: "3-5 Orders"
      }
      when: {
        sql: dt_customer_facts.total_orders >=6 and dt_customer_facts.total_orders <=9 ;;
        label: "6-9 Orders"
      }
      when: {
        sql: dt_customer_facts.total_orders >=10 ;;
        label: "10+ Orders"
      }
        }
      }

  dimension: customer_lifetime_revenue {
    type: tier
    tiers: [0,5,20,50,100,500,1000]
    style: relational
    sql: ${total_revenue} ;;
    value_format_name: usd
   }

  dimension: days_since_latest_order{
    type: duration_day
    sql_start: ${latest_order_raw} ;;
    sql_end:  CURRENT_DATE ;;
  }

  dimension: is_active {
    type: yesno
    sql: ${days_since_latest_order} <= 90 ;;
  }

  dimension: is_repeat_customer {
    type: yesno
    sql: ${customer_lifetime_orders} != '1 Order' AND ${customer_lifetime_orders} IS NOT NULL ;;
  }

#measure
  measure: total_lifetime_revenue {
    type: sum
    sql: ${total_revenue} ;;
    value_format_name: usd
    drill_fields: [customer_purchase_details.detail*]
  }

  measure: total_lifetime_orders {
    type: sum
    sql: ${total_orders} ;;
  }

  measure: average_lifetime_orders {
    type: average
    sql: ${total_orders} ;;
  }

  measure: average_lifetime_revenue {
     type: average
     sql: ${total_revenue} ;;
    value_format_name: usd
    }

  measure: average_days_since_latest_order {
    type: average
    sql: ${days_since_latest_order} ;;
  }





  set: detail {
    fields: [
      first_order_time,
      latest_order_time,
      total_lifetime_orders,
      total_lifetime_revenue,
      rank_by_number_orders
    ]
  }
}
