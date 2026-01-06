# ####################################################################

#  Created by Genus(TM) Synthesis Solution 21.14-s082_1 on Thu Dec 11 04:29:26 IST 2025

# ####################################################################

set sdc_version 2.0

set_units -capacitance 1000fF
set_units -time 1000ps

# Set the current design
current_design elevator_controller

create_clock -name "clk" -period 10.0 -waveform {0.0 5.0} [get_ports clk]
set_clock_transition 0.8 [get_clocks clk]
set_false_path -from [get_ports rst_n]
set_clock_gating_check -setup 0.0 
set_input_delay -clock [get_clocks clk] -add_delay -max 1.0 [get_ports rst_n]
set_input_delay -clock [get_clocks clk] -add_delay -max 1.0 [get_ports {in_car_req[7]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 1.0 [get_ports {in_car_req[6]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 1.0 [get_ports {in_car_req[5]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 1.0 [get_ports {in_car_req[4]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 1.0 [get_ports {in_car_req[3]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 1.0 [get_ports {in_car_req[2]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 1.0 [get_ports {in_car_req[1]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 1.0 [get_ports {in_car_req[0]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 1.0 [get_ports {hall_up_req[7]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 1.0 [get_ports {hall_up_req[6]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 1.0 [get_ports {hall_up_req[5]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 1.0 [get_ports {hall_up_req[4]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 1.0 [get_ports {hall_up_req[3]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 1.0 [get_ports {hall_up_req[2]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 1.0 [get_ports {hall_up_req[1]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 1.0 [get_ports {hall_up_req[0]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 1.0 [get_ports {hall_down_req[7]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 1.0 [get_ports {hall_down_req[6]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 1.0 [get_ports {hall_down_req[5]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 1.0 [get_ports {hall_down_req[4]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 1.0 [get_ports {hall_down_req[3]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 1.0 [get_ports {hall_down_req[2]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 1.0 [get_ports {hall_down_req[1]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 1.0 [get_ports {hall_down_req[0]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 1.0 [get_ports {floor_sensor[7]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 1.0 [get_ports {floor_sensor[6]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 1.0 [get_ports {floor_sensor[5]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 1.0 [get_ports {floor_sensor[4]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 1.0 [get_ports {floor_sensor[3]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 1.0 [get_ports {floor_sensor[2]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 1.0 [get_ports {floor_sensor[1]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 1.0 [get_ports {floor_sensor[0]}]
set_input_delay -clock [get_clocks clk] -add_delay -max 1.0 [get_ports door_open_sensor]
set_input_delay -clock [get_clocks clk] -add_delay -max 1.0 [get_ports door_closed_sensor]
set_input_delay -clock [get_clocks clk] -add_delay -max 1.0 [get_ports overload]
set_input_delay -clock [get_clocks clk] -add_delay -max 1.0 [get_ports emergency_stop]
set_input_delay -clock [get_clocks clk] -add_delay -max 1.0 [get_ports maintenance_mode]
set_input_delay -clock [get_clocks clk] -add_delay -max 1.0 [get_ports door_open_btn]
set_input_delay -clock [get_clocks clk] -add_delay -max 1.0 [get_ports door_close_btn]
set_output_delay -clock [get_clocks clk] -add_delay -max 1.0 [get_ports motor_up]
set_output_delay -clock [get_clocks clk] -add_delay -max 1.0 [get_ports motor_down]
set_output_delay -clock [get_clocks clk] -add_delay -max 1.0 [get_ports door_open_cmd]
set_output_delay -clock [get_clocks clk] -add_delay -max 1.0 [get_ports door_close_cmd]
set_output_delay -clock [get_clocks clk] -add_delay -max 1.0 [get_ports motor_brake]
set_output_delay -clock [get_clocks clk] -add_delay -max 1.0 [get_ports {current_floor[2]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 1.0 [get_ports {current_floor[1]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 1.0 [get_ports {current_floor[0]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 1.0 [get_ports {pending_debug[7]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 1.0 [get_ports {pending_debug[6]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 1.0 [get_ports {pending_debug[5]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 1.0 [get_ports {pending_debug[4]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 1.0 [get_ports {pending_debug[3]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 1.0 [get_ports {pending_debug[2]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 1.0 [get_ports {pending_debug[1]}]
set_output_delay -clock [get_clocks clk] -add_delay -max 1.0 [get_ports {pending_debug[0]}]
set_wire_load_mode "enclosed"
set_clock_uncertainty -setup 0.02 [get_clocks clk]
set_clock_uncertainty -hold 0.02 [get_clocks clk]
