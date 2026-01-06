# ============================================================
#  SDC for elevator_controller_predictive  (Legacy Genus)
# ============================================================

# 100 MHz clock (10 ns period)
create_clock -name clk -period 10 -waveform {0 5} [get_ports clk]

# Clock transition
set_clock_transition -rise 0.8 [get_clocks clk]
set_clock_transition -fall 0.8 [get_clocks clk]

# Clock uncertainty
set_clock_uncertainty 0.02 [get_clocks clk]

# Input delay (exclude clock)
set_input_delay -max 1.0 -clock clk \
    [remove_from_collection [all_inputs] [get_ports clk]]

# Output delay
set_output_delay -max 1.0 -clock clk [all_outputs]

# Async reset false path
set_false_path -from [get_ports rst_n]
