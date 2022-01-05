include: "/views/**/*.view"

explore: events {
  label: "Customer"
  join: users {
    type: left_outer
    sql_on: ${events.user_id}=${users.id} ;;
    relationship: many_to_one
  }
join: dt_customer_facts {
  view_label: "Customer facts"
  type: left_outer
  sql_on: ${dt_customer_facts.user_id}=${users.id} ;;
  relationship: one_to_one
  #fields: [dt_customer_facts.detail*]
}
join: customer_purchase_details {
  view_label: "Customer facts"
  type: left_outer
  sql_on: ${dt_customer_facts.user_id}=${customer_purchase_details.user_id} ;;
  relationship: one_to_many
  }

}
