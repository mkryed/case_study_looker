# Define the database connection to be used for this model.
connection: "snowlooker"

# include all the views

include: "/explore/*.explore"



# Datagroups define a caching policy for an Explore. To learn more,
# use the Quick Help panel on the right to see documentation.

datagroup: mikhail_case_study_default_datagroup {
  # sql_trigger: SELECT MAX(id) FROM etl_log;;
  max_cache_age: "1 hour"
}

persist_with: mikhail_case_study_default_datagroup

#creating a new value format
named_value_format: millions {
  value_format: "[>=1000000]0.00,,\"M\";[>=1000]0.00,\"K\";0.00"
}
# Explores allow you to join together different views (database tables) based on the
# relationships between fields. By joining a view into an Explore, you make those
# fields available to users for data analysis.
# Explores should be purpose-built for specific use cases.

# To see the Explore you’re building, navigate to the Explore menu and select an Explore under "Mikhail Case Study"

# To create more sophisticated Explores that involve multiple views, you can use the join parameter.
# Typically, join parameters require that you define the join type, join relationship, and a sql_on clause.
# Each joined view also needs to define a primary key.
