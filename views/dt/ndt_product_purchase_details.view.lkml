# If necessary, uncomment the line below to include explore_source.

# include: "order_items.explore.lkml"

view: product_purchase_details {
  derived_table: {
    explore_source: order_items {
      column: id { field: products.id }
      column: total_gross_revenue {}
      column: status {}
      column: count {}
    }
  }
  dimension: id {
    type: number
    primary_key: yes
  }
  dimension: total_gross_revenue {
    description: "Total revenue from completed sales (cancelled and returned orders excluded)"
    value_format: "$#,##0.00"
    type: number
  }
  dimension: status {}
  dimension: count {
    type: number
  }
  set: detail {
    fields: [id,total_gross_revenue,status,count]
  }
}
