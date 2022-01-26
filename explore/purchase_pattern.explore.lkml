include: "/views/*/*.view"
explore: purchase_pattern {
  label: "Customer Behaviour"
  from: order_items
  view_name: order_items
  join: dt_order_repurchase_facts {
    view_label: "Order Items Repurchase Facts"
    type: left_outer
    sql_on: ${order_items.id}=${dt_order_repurchase_facts.order_id} ;;
    relationship: one_to_one
  }

  join: inventory_items {
    type: left_outer
    sql_on: ${order_items.inventory_item_id}=${inventory_items.id} ;;
    relationship: many_to_one
  }

  join: users {
    type: left_outer
    sql_on: ${order_items.user_id}=${users.id} ;;
    relationship: many_to_one
  }
  join: dt_customer_facts {
    view_label: "Customer Behaviour Facts"
    type: left_outer
    sql_on: ${order_items.user_id}=${dt_customer_facts.user_id};;
    relationship:many_to_one
  }

  join: products {
    type: left_outer
    sql_on: ${inventory_items.product_id}=${products.id} ;;
    relationship: many_to_one
  }

}
