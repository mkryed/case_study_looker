include: "/views/**/*.view"

view: +users {

dimension: age_tier {
  type: tier
  tiers: [0,15,25,35,50,65]
  style: integer
  allow_fill: yes
  sql: ${age} ;;
}

dimension: days_since_signup {
  type: number
  sql: DATEDIFF( day, ${created_raw}, current_date) ;;
}

dimension: month_since_signup {
   type: number
  sql: DATEDIFF( month, ${created_raw}, current_date) ;;
}

dimension: days_since_signup_tier {
  type: tier
  tiers: [100,200,300,500,700,1000,1300]
  sql: ${days_since_signup} ;;
  style: integer
}

dimension: months_since_signup_tier{
  type: tier
  tiers: [4,8,12,16,20]
  sql: ${month_since_signup} ;;
  style: integer
}

measure:count_new_customer {
  description: "Number of new customers who signed up over the past 90 days"
  type: count
  filters: [created_date: "90 days ago"]
  drill_fields: [revenue_source_comparison_set*]
}

measure: avg_days_since_signup {
  type: average
  sql: ${days_since_signup} ;;
}

measure: avg_month_since_signup {
  type: average
  sql: ${month_since_signup} ;;
}

set: revenue_source_comparison_set {
  fields: [age_tier,gender,count_users,count_new_customer]
}
}
