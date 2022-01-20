include: "/views/*/*.view"
explore: customer_pattern {
  fields: [ALL_FIELDS*,-order_items.total_gross_margin]
  from: dt_customer_order_facts
  join: users {
   sql_on: ${customer_pattern.user_id}=${users.id} ;;
   type: left_outer
   relationship: many_to_one
  }
  join: order_items {
    sql_on: ${customer_pattern.order_id}=${order_items.order_id} ;;
    type: full_outer
    relationship: one_to_many
  }
}
