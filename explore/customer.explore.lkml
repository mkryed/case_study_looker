include: "/views/**/*.view"

explore: events {
  label: "Customer"
  join: users {
    type: left_outer
    sql_on: ${events.user_id}=${users.id} ;;
    relationship: many_to_one
  }
}
