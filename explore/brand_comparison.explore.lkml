include: "/views/refinements/*view"
explore: brand_comparison {
  from: order_items
  view_name: order_items
  fields: [ALL_FIELDS*,-order_items.total_gross_margin]
join: users {
  type: left_outer
  sql_on: ${order_items.user_id}=${users.id} ;;
  relationship: many_to_one
}
join: inventory_items {
  type: left_outer
  sql_on: ${order_items.inventory_item_id}=${inventory_items.id} ;;
  relationship: many_to_one
}
join: products {
  type: left_outer
  sql_on: ${inventory_items.product_id}=${products.id} ;;
  relationship: many_to_one
}
}
