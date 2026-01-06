`timescale 1ns/1ps

module elevator_controller_tb;

    reg         clk;
    reg         rst_n;

    reg  [7:0]  in_car_req;
    reg  [7:0]  hall_up_req;
    reg  [7:0]  hall_down_req;

    reg  [7:0]  floor_sensor;
    reg         door_open_sensor;
    reg         door_closed_sensor;

    reg         overload;
    reg         emergency_stop;
    reg         maintenance_mode;
    reg         door_open_btn;
    reg         door_close_btn;

    wire        motor_up;
    wire        motor_down;
    wire        door_open_cmd;
    wire        door_close_cmd;
    wire        motor_brake;
    wire [2:0]  current_floor;
    wire [7:0]  pending_debug;

    // DUT instantiation
    elevator_controller #(
        .FLOORS(8)
    ) DUT (
        .clk(clk),
        .rst_n(rst_n),
        .in_car_req(in_car_req),
        .hall_up_req(hall_up_req),
        .hall_down_req(hall_down_req),
        .floor_sensor(floor_sensor),
        .door_open_sensor(door_open_sensor),
        .door_closed_sensor(door_closed_sensor),
        .overload(overload),
        .emergency_stop(emergency_stop),
        .maintenance_mode(maintenance_mode),
        .door_open_btn(door_open_btn),
        .door_close_btn(door_close_btn),
        .motor_up(motor_up),
        .motor_down(motor_down),
        .door_open_cmd(door_open_cmd),
        .door_close_cmd(door_close_cmd),
        .motor_brake(motor_brake),
        .current_floor(current_floor),
        .pending_debug(pending_debug)
    );

    // Clock generation (100 MHz -> 10 ns period)
    always #5 clk = ~clk;

    // Helper: set one-hot floor sensor
    task set_floor(input integer f);
    begin
        case (f)
            0: floor_sensor = 8'b0000_0001;
            1: floor_sensor = 8'b0000_0010;
            2: floor_sensor = 8'b0000_0100;
            3: floor_sensor = 8'b0000_1000;
            4: floor_sensor = 8'b0001_0000;
            5: floor_sensor = 8'b0010_0000;
            6: floor_sensor = 8'b0100_0000;
            7: floor_sensor = 8'b1000_0000;
            default: floor_sensor = 8'b0000_0001;
        endcase
    end
    endtask

    initial begin
        // Waveform dump (for some simulators; ModelSim ignores)
        // $dumpfile("elevator.vcd");
        // $dumpvars(0, elevator_controller_tb);

        // Initial values
        clk             = 1'b0;
        rst_n           = 1'b0;

        in_car_req      = 8'd0;
        hall_up_req     = 8'd0;
        hall_down_req   = 8'd0;

        set_floor(0); // start at floor 0

        door_open_sensor   = 1'b0;
        door_closed_sensor = 1'b1;

        overload         = 1'b0;
        emergency_stop   = 1'b0;
        maintenance_mode = 1'b0;
        door_open_btn    = 1'b0;
        door_close_btn   = 1'b0;

        // Reset
        #50  rst_n = 1'b1;

        // -------------------------------------------------------
        // Test 1: Car request from floor 0 -> 3
        // -------------------------------------------------------
        #20  in_car_req = 8'b0000_1000;   // request floor 3
        #20  in_car_req = 8'b0000_0000;

        // Simulate passing floors 1,2,3
        #100 set_floor(1);
        #100 set_floor(2);
        #100 set_floor(3);

        // Door opening at floor 3
        #20  door_closed_sensor = 1'b0;
             door_open_sensor   = 1'b1;

        #100 door_open_sensor   = 1'b0;
             door_close_btn     = 1'b1;   // user presses close
        #40  door_close_btn     = 1'b0;
             door_closed_sensor = 1'b1;

        // -------------------------------------------------------
        // Test 2: Hall up request at floor 1, hall down at floor 7
        // -------------------------------------------------------
        #100 set_floor(3); // assume elevator currently at 3

        #20  hall_up_req  = 8'b0000_0010; // floor 1 up
             hall_down_req= 8'b1000_0000; // floor 7 down
        #20  hall_up_req  = 8'b0000_0000;
             hall_down_req= 8'b0000_0000;

        // Move down to 1 first
        #80  set_floor(2);
        #80  set_floor(1);

        // Door open at 1
        #20  door_closed_sensor = 1'b0;
             door_open_sensor   = 1'b1;
        #80  door_open_sensor   = 1'b0;
             door_closed_sensor = 1'b1;

        // Now move up to 7
        #80  set_floor(2);
        #80  set_floor(3);
        #80  set_floor(4);
        #80  set_floor(5);
        #80  set_floor(6);
        #80  set_floor(7);

        // Door open at 7
        #20  door_closed_sensor = 1'b0;
             door_open_sensor   = 1'b1;
        #80  door_open_sensor   = 1'b0;
             door_closed_sensor = 1'b1;

        // -------------------------------------------------------
        // Test 3: Emergency stop while moving
        // -------------------------------------------------------
        #100 in_car_req = 8'b0001_0000;  // request floor 4
        #20  in_car_req = 8'b0000_0000;

        // start moving from floor 7 downwards
        #80  set_floor(6);
        #40  emergency_stop = 1'b1;      // trigger emergency
        #100 emergency_stop = 1'b0;      // clear emergency

        // -------------------------------------------------------
        // Finish simulation
        // -------------------------------------------------------
        #300 $stop;
    end

endmodule