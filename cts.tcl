# -------------------------------------
# CTS Script for Elevator Controller
# -------------------------------------

add_ndr -width {Metal5 0.28 Metal6 0.28} \
        -spacing {Metal5 0.28 Metal6 0.28} \
        -name clk_ndr

create_route_type \
    -name clkroute \
    -non_default_rule clk_ndr \
    -bottom_preferred_layer Metal5 \
    -top_preferred_layer Metal6

set_ccopt_property route_type clkroute -net_type trunk
set_ccopt_property route_type clkroute -net_type leaf

set_ccopt_property buffer_cells {CLKBUFX3 CLKBUFX4 CLKBUFX6}
set_ccopt_property inverter_cells {CLKINVX3 CLKINVX4 CLKINVX6}

create_ccopt_clock_tree_spec -file ccopt.spec
source ccopt.spec

ccopt_design -cts

report_ccopt_clock_trees  -file clk_trees.rpt
report_ccopt_skew_groups -file skew_groups.rpt

saveDesign DBS/cts.enc
