#################### Connection Definition ######################
connection: "looker_partner_demo"

#################### explore, datagroups includes ###############
include: "/explores/*.explore"
include: "/datagroups.lkml"

#################### Caching policy #############################
persist_with: the24hourupdate

#################### New name_value_format ######################
named_value_format: millions {
  value_format: "[>=1000000]0.00,,\"M\";[>=1000]0.00,\"K\";0.00"
}
