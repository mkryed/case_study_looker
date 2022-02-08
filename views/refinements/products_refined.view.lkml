include: "/views/**/*.view"

view: +products {

  dimension: brand {
    type: string
    sql: ${TABLE}."BRAND" ;;
    link: {
      label: "Google"
      url: "http://www.google.com/search?q={{ value }}"
      icon_url: "http://google.com/favicon.ico"
      }
    link: {
      label: "Facebook"
      url: "https://www.facebook.com/public/{{ value}}"
      icon_url: "https://facebook.com/favicon.ico"
    }
    link: {
      label: "Go to Brand Comparison"
      url: "https://montrealanalytics.ca.looker.com/dashboards/110?Insert+Brand+to+Compare={{ value }}"
    }
  }
    dimension: category {
    type: string
    sql:
            ${TABLE}."CATEGORY"
             ;;
    link: {
      label: "Category & Brand Info"
      url: "https://montrealanalytics.ca.looker.com/dashboards/100?Category={{ value | url_encode }}&Brand={{
      _filters['products.brand'] | url_encode }}"
    }
  }

  filter: insert_brand_to_compare {
    description: "Choose the brand you wish to compare with the rest of the population or with another brand"
    suggest_dimension: products.brand
  }


  dimension: brand_comparator {

    type: string
    sql: CASE
            WHEN{% condition insert_brand_to_compare %}
            ${products.brand}
            {% endcondition %} THEN  ${products.brand}
            ELSE 'Rest of Brands'
            END;;
  }





  set:order_items  {
    fields: [brand,category,average_cost,cost,count,department,distribution_center_id,id,name,retail_price,sku,total_cost]
  }


}
