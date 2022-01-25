
include: "/views/*/*.view"

include: "/views/raw/*.view"

explore: order_items {
  description: "Detailed order information"

  join: dt_order_items_fcts {
    view_label: "Order Items"
    type: left_outer
    relationship: one_to_one
    sql_on: ${dt_order_items_fcts.id}=${order_items.id} ;;
    fields: [dt_order_items_fcts.dt_order*]
  }

  join: inventory_items {
    type: left_outer
    sql_on: ${order_items.inventory_item_id}=${inventory_items.id} ;;
    relationship: many_to_one
      }

  join: users {
    type: full_outer
    sql_on: ${order_items.user_id}=${users.id} ;;
    relationship: many_to_one
  }
  join: products {
    type: left_outer
    sql_on: ${products.id}=${inventory_items.product_id} ;;
    relationship: many_to_one
  }
  join: distribution_centers {
    type: left_outer
    sql_on: ${distribution_centers.id}=${products.distribution_center_id} ;;
    relationship: many_to_one
  }
  join: events {
    type: full_outer
    sql_on: ${events.user_id}=${users.id} ;;
    relationship: many_to_one
  }


}
