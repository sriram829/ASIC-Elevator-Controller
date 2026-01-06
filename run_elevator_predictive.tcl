puts "===> Starting Elevator Predictive Synthesis (Legacy Genus Mode)..."

# -------------------------
# Library Setup
# -------------------------
set_attribute init_lib_search_path /home/install/FOUNDRY/digital/90nm/dig/lib
set_attribute library typical.lib

# -------------------------
# Read RTL (design only)
# -------------------------
read_hdl {./elevator_predictive.v}

# -------------------------
# Elaborate correct module name
# -------------------------
elaborate elevator_controller
set_top_module elevator_controller

# -------------------------
# Read timing constraints
# -------------------------
read_sdc ./elevator.sdc

# -------------------------
# Synthesis effort
# -------------------------
set_attribute syn_generic_effort medium
set_attribute syn_map_effort     medium
set_attribute syn_opt_effort     medium

# -------------------------
# Synthesis
# -------------------------
syn_generic
syn_map
syn_opt

# -------------------------
# Write results
# -------------------------
write_hdl > elevator_netlist.v
write_sdc > elevator_tool.sdc

# -------------------------
# Reports
# -------------------------
report timing > elevator_timing.rpt
report power  > elevator_power.rpt
report area   > elevator_area.rpt
report gates  > elevator_gates.rpt

puts "===> Elevator Predictive Synthesis Completed!"
gui_show
