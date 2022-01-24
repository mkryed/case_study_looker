include: "/views/raw/*view"

view: +inventory_items {

  measure: total_cost_sold_items {
    description: "Total cost of items sold from inventory"
    type: sum
    sql: ${cost} ;;
    filters: [sold_date: "-NULL",order_items.status: "Complete,Processing,Shipped"]
    value_format_name: usd
  }

  measure: average_total_cost_sold_items {
    description: "Average cost of items sold from inventory"
    type: average
    sql: ${cost} ;;
    filters: [sold_date: "-NULL",order_items.status: "Complete,Processing,Shipped"]
    value_format_name: usd
  }

}
