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
      label: "Go to customer Behaviour"
      url: "https://montrealanalytics.ca.looker.com/dashboards/100?Brand={{ value }}"
    }
  }
    dimension: category {
    type: string
    sql: ${TABLE}."CATEGORY" ;;
    link: {
      label: "Category & Brand Info"
      url: "https://montrealanalytics.ca.looker.com/dashboards/100?Category={{ value | url_encode }}&Brand={{
      _filters['products.brand'] | url_encode }}"
    }
  }
}
