include: "/views/**/customer_order_facts.view"

explore: customer_pattern{
  from: customer_order_facts
# label: "Customer Pattern"
}
