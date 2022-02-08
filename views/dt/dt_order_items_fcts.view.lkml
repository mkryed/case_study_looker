view: dt_order_items_fcts {
  derived_table: {
    sql: select
      id,

      sum(sale_price) OVER (ORDER BY id ASC) as running_total
      from order_items

             ;;
  }

  dimension: id {
    type: number
    sql: ${TABLE}."ID" ;;
    primary_key: yes
  }

  dimension: running_total {
    description: "Cummulative total sales from items sold (also known as running total)"
    type: number
    sql: ${TABLE}."RUNNING_TOTAL" ;;
  }
}
