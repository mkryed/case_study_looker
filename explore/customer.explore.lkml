include: "/views/**/*.view"

explore: users {
  label: "Customer"
  fields: [ALL_FIELDS*,-order_items.total_gross_margin]

join: dt_customer_facts {
  view_label: "Customer facts"
  type: left_outer
  sql_on: ${dt_customer_facts.user_id}=${users.id} ;;
  relationship: one_to_one
  #fields: [dt_customer_facts.detail*]
}

join: order_items {
  type: left_outer
  sql_on: ${users.id}=${order_items.user_id} ;;
  relationship: one_to_many
  }

  join: inventory_items {
    type: left_outer
    sql_on: ${order_items.inventory_item_id}=${inventory_items.id} ;;
    relationship: many_to_one
  }

  join: products {
    type: left_outer
    sql_on: ${products.id}=${inventory_items.product_id} ;;
    relationship: many_to_one
  }
}
