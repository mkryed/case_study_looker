include: "/views/**/*.view"

view: +users {



dimension: age_tier {
  type: tier
  tiers: [15,25,35,50,65]
  style: integer
  allow_fill: yes
  sql: ${age} ;;
}

measure: proportion_of_customer {
  type: percent_of_total
  sql: ${count_users} ;;
}


measure:count_new_customer {
  label: "Number of new customers"
  group_label: "Count"
  description: "Number of new customers who signed up over the past 90 days"
  type: count
  filters: [created_date: "90 days ago"]
  drill_fields: [revenue_source_comparison_set*]
}

  dimension_group: since_signup {
    type: duration
    intervals: [day, month]
    sql_start: ${users.created_raw} ;;
    sql_end: CURRENT_TIMESTAMP() ;;
  }


  dimension: users_months_since_signup_tier {
    description: "The number of months since a customer has signed up on the
    website"
    group_label: "Tier"
    type: tier
    tiers: [1,2,3,6,12]
    style: integer
    sql: ${months_since_signup} ;;
  }

  dimension: user_days_since_signup_tier {
    description: "The number of days since a customer has signed up on the
    website"
    group_label: "Tier"
    type: tier
    style: integer
    tiers: [10,50,100,200,350]
    sql: ${days_since_signup} ;;
  }

  measure: avg_months_since_signup {
    group_label: "Average"
    type: average
    sql: ${months_since_signup} ;;
    description: "Average number of months between a customer initially
    registering on the website and now"
  }

  measure: avg_days_since_signup {
    group_label: "Average"
    type: average
    sql: ${days_since_signup} ;;
    description: "Average number of days between a customer initially
    registering on the website and now"
  }

  #MOM AnALYSIS

  dimension: is_month_to_date {
    type: yesno
    sql: ${created_day_of_month} <= day(current_date()) ;;
  }

  dimension: is_year_to_date {
    type: yesno
    sql: ${created_day_of_year} <= dayofyear(current_date()) ;;
  }

  dimension: is_customer_new {
    type: yesno
    sql: DATEDIFF( day,${created_date},CURRENT_DATE()  ) <= 90 ;;
  }

set: revenue_source_comparison_set {
  fields: [age_tier,gender,count_users,count_new_customer]
}
}
