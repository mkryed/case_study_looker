view: dt_order_items_fcts {
  derived_table: {
    sql: select
      id
      ,created_at
      ,delivered_at
      ,inventory_item_id
      ,order_id
      ,returned_at
      ,sale_price
      ,shipped_at
      ,status
      ,user_id
      ,sum(sale_price) OVER (ORDER BY id ASC) as running_total
      from order_items

             ;;
  }

  measure: count {
    type: count
    drill_fields: [dt_order*]
  }

  dimension: id {
    type: number
    sql: ${TABLE}."ID" ;;
  }

  dimension_group: created_at {
    type: time
    sql: ${TABLE}."CREATED_AT" ;;
  }

  dimension_group: delivered_at {
    type: time
    sql: ${TABLE}."DELIVERED_AT" ;;
  }

  dimension: inventory_item_id {
    type: number
    sql: ${TABLE}."INVENTORY_ITEM_ID" ;;
  }

  dimension: order_id {
    type: number
    sql: ${TABLE}."ORDER_ID" ;;
  }

  dimension_group: returned_at {
    type: time
    sql: ${TABLE}."RETURNED_AT" ;;
  }

  dimension: sale_price {
    type: number
    sql: ${TABLE}."SALE_PRICE" ;;
  }

  dimension_group: shipped_at {
    type: time
    sql: ${TABLE}."SHIPPED_AT" ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}."STATUS" ;;
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}."USER_ID" ;;
  }

  dimension: running_total {
    description: "Cummulative total sales from items sold (also known as running total)"
    type: number
    sql: ${TABLE}."RUNNING_TOTAL" ;;
  }

  #Measure

  set: dt_order {
    fields: [
           running_total
    ]
  }
}
