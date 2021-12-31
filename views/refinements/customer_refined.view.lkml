include: "/views/**/*.view"

view: +users {

dimension: age_tier {
  type: tier
  tiers: [0,15,25,35,50,65]
  style: integer
  allow_fill: yes
  sql: ${age} ;;
}

measure:count_new_customer {
  description: "Number of new customers who signed up over the past 90 days"
  type: count
  filters: [created_date: "90 days ago"]
  drill_fields: [revenue_source_comparison_set*]
}

set: revenue_source_comparison_set {
  fields: [age_tier,gender,count_users,count_new_customer]
}
}
