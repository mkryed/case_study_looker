view: sql_runner_query {
  derived_table: {
    sql: select a.user_id,
      a.inventory_item_id,
      a.order_id,
      a.sale_price,
      b.product_id,
      b.product_brand as product_brand,
      b.product_category as product_category,
      b.product_department as product_department
      from order_items a
      JOIN inventory_items b
      ON a.inventory_item_id=b.id
      order by a.user_id
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}."USER_ID" ;;
  }

  dimension: inventory_item_id {
    type: number
    sql: ${TABLE}."INVENTORY_ITEM_ID" ;;
  }

  dimension: order_id {
    type: number
    sql: ${TABLE}."ORDER_ID" ;;
  }

  dimension: sale_price {
    type: number
    sql: ${TABLE}."SALE_PRICE" ;;
  }

  dimension: product_id {
    type: number
    sql: ${TABLE}."PRODUCT_ID" ;;
  }

  dimension: product_brand {
    type: string
    sql: ${TABLE}."PRODUCT_BRAND" ;;
  }

  dimension: product_category {
    type: string
    sql: ${TABLE}."PRODUCT_CATEGORY" ;;
  }

  dimension: product_department {
    type: string
    sql: ${TABLE}."PRODUCT_DEPARTMENT" ;;
  }

  set: detail {
    fields: [
      user_id,
      inventory_item_id,
      order_id,
      sale_price,
      product_id,
      product_brand,
      product_category,
      product_department
    ]
  }
}
