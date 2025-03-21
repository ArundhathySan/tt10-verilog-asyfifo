`default_nettype none

module tt_um_asyfifo (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       rst_n     // reset_n - low to reset
);

    parameter DEPTH = 8;  // FIFO depth (small for Tiny Tapeout)
    
    // Signal mapping
    wire wclk  = ui_in[2]; // Write clock
    wire rclk  = ui_in[3]; // Read clock
    wire we    = ui_in[0]; // Write enable
    wire re    = ui_in[1]; // Read enable
    wire rst   = ~ui_in[4]; // Active-high reset
    wire [3:0] data_in = uio_in[3:0]; // 4-bit data input

    // FIFO memory and control signals
    reg [3:0] mem [0:DEPTH-1];
    reg [2:0] w_ptr = 0, r_ptr = 0; // 3-bit pointers for 8-depth FIFO
    reg [2:0] count = 0;  // Track FIFO occupancy
    reg [3:0] data_out;

    // FIFO Write Operation
    always @(posedge wclk or posedge rst) begin
        if (rst) begin
            w_ptr <= 0;
        end else if (we && count < DEPTH) begin
            mem[w_ptr] <= data_in;
            w_ptr <= (w_ptr + 1) & (DEPTH - 1);  // Wrap-around logic using bitwise AND
        end
    end

    // FIFO Read Operation
    always @(posedge rclk or posedge rst) begin
        if (rst) begin
            r_ptr <= 0;
        end else if (re && count > 0) begin
            data_out <= mem[r_ptr];
            r_ptr <= (r_ptr + 1) & (DEPTH - 1); // Wrap-around logic using bitwise AND
        end
    end

    // FIFO Count Management (Separate Blocks for Read & Write)
    always @(posedge wclk or posedge rst) begin
        if (rst) begin
            count <= 0;
        end else if (we && count < DEPTH) begin
            count <= count + 1; // Increment on write
        end
    end

    always @(posedge rclk or posedge rst) begin
        if (rst) begin
            count <= 0;
        end else if (re && count > 0) begin
            count <= count - 1; // Decrement on read
        end
    end

    // Output assignments
    assign uo_out[3:0] = data_out; // 4-bit data output
    assign uo_out[4]   = (count == 0);  // Empty flag
    assign uo_out[5]   = (count == DEPTH); // Full flag
    assign uo_out[7:6] = 2'b00; // Reserved for future use
    assign uio_out     = 8'b0;  // No output on IOs
    assign uio_oe      = 8'b0;  // Set IOs to input mode

    // Prevent warnings for unused signals
    (* unused *) wire [7:5] unused_ui_in = ui_in[7:5];
    (* unused *) wire [7:4] unused_uio_in = uio_in[7:4];

endmodule


  
