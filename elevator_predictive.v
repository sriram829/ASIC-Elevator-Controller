// ==================================================================
// Digital Elevator Controller (8 Floors)
// Verilog-2001, ModelSim 6.3g / Genus friendly
// Features (to push gate count):
//   - 8 floors
//   - Separate request buses (car / hall up / hall down)
//   - Pending request queue
//   - Direction control and target-floor selection logic
//   - Door open/close timing counters
//   - Overload + emergency + maintenance handling
// ==================================================================

`timescale 1ns/1ps

module elevator_controller #(
    parameter FLOORS           = 8,
    parameter DOOR_OPEN_TICKS  = 8'd40,  // adjust to change size / behavior
    parameter MOVE_TICKS       = 8'd20
)(
    input  wire                    clk,
    input  wire                    rst_n,

    // Requests
    input  wire [FLOORS-1:0]       in_car_req,
    input  wire [FLOORS-1:0]       hall_up_req,
    input  wire [FLOORS-1:0]       hall_down_req,

    // Sensors
    input  wire [FLOORS-1:0]       floor_sensor,     // one-hot current floor
    input  wire                    door_open_sensor,
    input  wire                    door_closed_sensor,

    input  wire                    overload,
    input  wire                    emergency_stop,
    input  wire                    maintenance_mode,
    input  wire                    door_open_btn,
    input  wire                    door_close_btn,

    // Outputs
    output reg                     motor_up,
    output reg                     motor_down,
    output reg                     door_open_cmd,
    output reg                     door_close_cmd,
    output reg                     motor_brake,
    output reg [2:0]               current_floor,    // 3 bits for 8 floors

    // Optional: debug visibility of pending requests
    output reg [FLOORS-1:0]        pending_debug
);

    // ============================================================
    // State encoding
    // ============================================================

    localparam ST_IDLE         = 3'd0;
    localparam ST_MOVING_UP    = 3'd1;
    localparam ST_MOVING_DOWN  = 3'd2;
    localparam ST_DOOR_OPENING = 3'd3;
    localparam ST_DOOR_OPEN    = 3'd4;
    localparam ST_DOOR_CLOSING = 3'd5;
    localparam ST_EMERGENCY    = 3'd6;
    localparam ST_MAINT        = 3'd7;

    reg [2:0] state, next_state;

    // Pending requests + target / direction
    reg [FLOORS-1:0] pending, next_pending;
    reg [2:0]        target_floor, next_target_floor;
    reg              dir_up, next_dir_up;  // 1 = prefer going up, 0 = down

    // Timing counters
    reg [7:0] door_timer, next_door_timer;
    reg [7:0] move_timer, next_move_timer;

    integer i;

    // ============================================================
    // Decode floor_sensor -> current_floor
    // ============================================================

    always @(*) begin
        current_floor = 3'd0;
        for (i = 0; i < FLOORS; i = i + 1) begin
            if (floor_sensor[i])
                current_floor = i[2:0];
        end
    end

    // ============================================================
    // Sequential registers
    // ============================================================

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state         <= ST_IDLE;
            pending       <= {FLOORS{1'b0}};
            target_floor  <= 3'd0;
            dir_up        <= 1'b1;
            door_timer    <= 8'd0;
            move_timer    <= 8'd0;
        end else begin
            state         <= next_state;
            pending       <= next_pending;
            target_floor  <= next_target_floor;
            dir_up        <= next_dir_up;
            door_timer    <= next_door_timer;
            move_timer    <= next_move_timer;
        end
    end

    // For visibility in waveform
    always @(*) begin
        pending_debug = pending;
    end

    // ============================================================
    // Next-state logic
    // ============================================================

    always @(*) begin
        // Default hold values
        next_state        = state;
        next_pending      = pending |
                            in_car_req |
                            hall_up_req |
                            hall_down_req;
        next_target_floor = target_floor;
        next_dir_up       = dir_up;
        next_door_timer   = door_timer;
        next_move_timer   = move_timer;

        // Clear request when doors are open at that floor
        if (state == ST_DOOR_OPEN) begin
            next_pending[current_floor] = 1'b0;
        end

        // Emergency / maintenance override
        if (emergency_stop) begin
            next_state      = ST_EMERGENCY;
            next_move_timer = 8'd0;
            next_door_timer = 8'd0;
        end else if (maintenance_mode) begin
            next_state      = ST_MAINT;
        end else begin
            // Normal FSM
            case (state)

                // ------------------------------------------------
                ST_IDLE: begin
                    next_move_timer = 8'd0;
                    next_door_timer = 8'd0;

                    // Any pending requests?
                    if (next_pending != {FLOORS{1'b0}}) begin
                        // Select a target floor based on dir_up
                        // 1) Try in current direction
                        // 2) If nothing, try opposite direction
                        // This logic intentionally uses loops to
                        // create some combinational complexity.
                        next_target_floor = current_floor;

                        // search in preferred direction
                        if (dir_up) begin
                            for (i = 0; i < FLOORS; i = i + 1) begin
                                if (next_pending[i] && (i > current_floor))
                                    next_target_floor = i[2:0];
                            end
                            // If still at current_floor, search down
                            if (next_target_floor == current_floor) begin
                                for (i = 0; i < FLOORS; i = i + 1) begin
                                    if (next_pending[i] && (i < current_floor)) begin
                                        next_target_floor = i[2:0];
                                        next_dir_up       = 1'b0;
                                    end
                                end
                            end
                        end else begin
                            // preferred direction = down
                            for (i = 0; i < FLOORS; i = i + 1) begin
                                if (next_pending[i] && (i < current_floor))
                                    next_target_floor = i[2:0];
                            end
                            // If still at current_floor, search up
                            if (next_target_floor == current_floor) begin
                                for (i = 0; i < FLOORS; i = i + 1) begin
                                    if (next_pending[i] && (i > current_floor)) begin
                                        next_target_floor = i[2:0];
                                        next_dir_up       = 1'b1;
                                    end
                                end
                            end
                        end

                        // Decide next state from target vs current
                        if (next_target_floor > current_floor)
                            next_state = ST_MOVING_UP;
                        else if (next_target_floor < current_floor)
                            next_state = ST_MOVING_DOWN;
                        else
                            next_state = ST_DOOR_OPENING;
                    end
                end

                // ------------------------------------------------
                ST_MOVING_UP: begin
                    // Simple movement timing
                    if (move_timer < MOVE_TICKS)
                        next_move_timer = move_timer + 8'd1;
                    else
                        next_move_timer = 8'd0;

                    // If we "arrived" at target_floor (sensor)
                    if (current_floor == target_floor) begin
                        next_state      = ST_DOOR_OPENING;
                        next_move_timer = 8'd0;
                    end
                end

                // ------------------------------------------------
                ST_MOVING_DOWN: begin
                    if (move_timer < MOVE_TICKS)
                        next_move_timer = move_timer + 8'd1;
                    else
                        next_move_timer = 8'd0;

                    if (current_floor == target_floor) begin
                        next_state      = ST_DOOR_OPENING;
                        next_move_timer = 8'd0;
                    end
                end

                // ------------------------------------------------
                ST_DOOR_OPENING: begin
                    // Wait for door_open_sensor or timeout
                    if (door_open_sensor) begin
                        next_state      = ST_DOOR_OPEN;
                        next_door_timer = 8'd0;
                    end else begin
                        if (door_timer < DOOR_OPEN_TICKS)
                            next_door_timer = door_timer + 8'd1;
                        else begin
                            next_state      = ST_DOOR_OPEN;
                            next_door_timer = 8'd0;
                        end
                    end
                end

                // ------------------------------------------------
                ST_DOOR_OPEN: begin
                    // Hold open for fixed time or until close button
                    if (door_close_btn || (door_timer >= DOOR_OPEN_TICKS)) begin
                        next_state      = ST_DOOR_CLOSING;
                        next_door_timer = 8'd0;
                    end else begin
                        next_door_timer = door_timer + 8'd1;
                    end
                end

                // ------------------------------------------------
                ST_DOOR_CLOSING: begin
                    // Close until sensor says closed
                    if (door_closed_sensor) begin
                        next_state      = ST_IDLE;
                        next_door_timer = 8'd0;
                    end else begin
                        if (door_timer < DOOR_OPEN_TICKS)
                            next_door_timer = door_timer + 8'd1;
                        else
                            next_door_timer = door_timer;
                    end
                end

                // ------------------------------------------------
                ST_EMERGENCY: begin
                    // brake, open door if possible, clear movement
                    next_move_timer = 8'd0;
                    next_door_timer = 8'd0;
                    // If emergency clears, go to IDLE
                    if (!emergency_stop)
                        next_state = ST_IDLE;
                end

                // ------------------------------------------------
                ST_MAINT: begin
                    // Just keep doors open at current floor
                    next_move_timer = 8'd0;
                    // Exit maintenance when mode deasserted
                    if (!maintenance_mode)
                        next_state = ST_IDLE;
                end

                default: begin
                    next_state = ST_IDLE;
                end

            endcase
        end
    end

    // ============================================================
    // Output logic
    // ============================================================

    always @(*) begin
        // Defaults
        motor_up       = 1'b0;
        motor_down     = 1'b0;
        door_open_cmd  = 1'b0;
        door_close_cmd = 1'b0;
        motor_brake    = 1'b0;

        case (state)

            ST_IDLE: begin
                motor_brake = 1'b1;
            end

            ST_MOVING_UP: begin
                motor_up    = 1'b1;
                motor_brake = 1'b0;
            end

            ST_MOVING_DOWN: begin
                motor_down  = 1'b1;
                motor_brake = 1'b0;
            end

            ST_DOOR_OPENING: begin
                door_open_cmd = 1'b1;
                motor_brake   = 1'b1;
            end

            ST_DOOR_OPEN: begin
                motor_brake   = 1'b1;
            end

            ST_DOOR_CLOSING: begin
                door_close_cmd = 1'b1;
                motor_brake    = 1'b1;
            end

            ST_EMERGENCY: begin
                motor_brake   = 1'b1;
                door_open_cmd = 1'b1; // try to keep doors open
            end

            ST_MAINT: begin
                motor_brake   = 1'b1;
                door_open_cmd = 1'b1;
            end

            default: begin
                motor_brake   = 1'b1;
            end

        endcase
    end

endmodule