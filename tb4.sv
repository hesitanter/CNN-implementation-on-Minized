

module tb();
    logic         clk;
    logic  [31:0] ps_control;
    logic  [31:0] pl_status;
    logic         reset_x_1;
    logic [19:0] addr_x_1; // 32*32*64*4 = 262144; 需要19位宽
    logic signed [31:0] data_in_x_1;
    logic [31:0] data_out_x_1;
    logic [3:0]  we_x_1;
    logic         reset_x_2;
    logic [19:0] addr_x_2; // 32*32*64*4 = 262144; 需要19位宽
    logic signed [31:0] data_in_x_2;
    logic [31:0] data_out_x_2;
    logic [3:0]  we_x_2;
    logic         reset_x_3;
    logic [19:0] addr_x_3; // 32*32*64*4 = 262144; 需要19位宽
    logic signed [31:0] data_in_x_3;
    logic [31:0] data_out_x_3;
    logic [3:0]  we_x_3;
    logic         reset_y_1;
    logic [31:0] data_in_y_1;
    logic [18:0] addr_y_1; 
    logic [3:0]  we_y_1;
    logic [31:0] final_y_1;
    logic         reset_y_2;
    logic [31:0] data_in_y_2;
    logic [18:0] addr_y_2; 
    logic [3:0]  we_y_2;
    logic signed [31:0] final_y_2;
    logic         reset_w;
    logic [8:0]  addr_w; // 3*3*4 = 36; 需要6位宽
    logic signed [31:0] data_in_w;
    logic [31:0] data_out_w;
    logic [3:0]  we_w;
    logic en_w_a;

    initial clk = 0;
    always #5 clk = ~clk;

    K_k_3_2 inst( .clk(clk), .ps_control(ps_control), .pl_status(pl_status), .reset_x_1(reset_x_1), .addr_x_1(addr_x_1), .data_in_x_1(data_in_x_1), .data_out_x_1(data_out_x_1), .we_x_1(we_x_1),
                                                                             .reset_x_2(reset_x_2), .addr_x_2(addr_x_2), .data_in_x_2(data_in_x_2), .data_out_x_2(data_out_x_2), .we_x_2(we_x_2),
                                                                             .reset_x_3(reset_x_3), .addr_x_3(addr_x_3), .data_in_x_3(data_in_x_3), .data_out_x_3(data_out_x_3), .we_x_3(we_x_3),
                                                                             .reset_y_1(reset_y_1), .addr_y_1(addr_y_1), .data_in_y_1(data_in_y_1), .final_y_1(final_y_1), .we_y_1(we_y_1),
                                                                             .reset_y_2(reset_y_2), .addr_y_2(addr_y_2), .data_in_y_2(data_in_y_2), .final_y_2(final_y_2), .we_y_2(we_y_2),
                                                                             .reset_w(reset_w),     .addr_w(addr_w),     .data_in_w(data_in_w),     .data_out_w(data_out_w),     .we_w(we_w), .en_w_a(en_w_a));

    logic [31:0] mem_x_1 [1023:0]; // 32*32 = 1024个
    logic [31:0] mem_x_2 [1023:0]; // 32*32 = 1024个
    logic [31:0] mem_x_3 [1023:0]; // 32*32 = 1024个

    logic [31:0] mem_w_1 [54:0];

    logic [31:0] mem_y_1 [899:0]; // 30*30 = 900个
    logic [31:0] mem_y_2 [899:0]; // 30*30 = 900个


    initial $readmemh("data_1024_x.hex", mem_x_1); 
    initial $readmemh("data_1024_x.hex", mem_x_2); 
    initial $readmemh("data_1024_x.hex", mem_x_3); 

    initial $readmemh("data_9_w.hex", mem_w_1); 
    initial addr_w = 0;
    initial en_w_a = 1;
    initial we_w = 1;
    initial data_in_w = 2;

    always @(posedge clk) begin
        data_in_x_1 <= mem_x_1[addr_x_1[19:2]];
        data_in_x_2 <= mem_x_2[addr_x_2[19:2]];
        data_in_x_3 <= mem_x_3[addr_x_3[19:2]];

        data_in_w <= mem_w_1[addr_w[8:2]];
        addr_w <= addr_w + 4;

        mem_y_1[addr_y_1[18:2]] <= final_y_1;
        mem_y_2[addr_y_2[18:2]] <= final_y_2;
    end

    integer file_id;
    integer i;
    initial begin 
        $display("ok");
        $display("%d\n", mem_w_1[26]);
        $display("%d\n", mem_x_1[1023]);
        #540;
        en_w_a = 0; we_w = 0;

        reset_x_1 = 1; reset_x_2 = 1; reset_x_3 = 1;
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        #1; reset_x_1 = 0; reset_x_2 = 0; reset_x_3 = 0;

        @(posedge clk); 
        @(posedge clk); 
        #1; ps_control = 1; 

        wait(pl_status[0] == 1'b1); 
        @(posedge clk); 
        #1; ps_control = 0; 

        $display("waiting");
        wait(pl_status[0] == 1'b0); 
        #100; 


        file_id = $fopen("data_900_y_1.hex");
        for (i = 0; i < 900; i++) begin
            $fdisplay(file_id, "%d", mem_y_1[i]);
        end
        $fclose(file_id);

        file_id = $fopen("data_900_y_2.hex");
        for (i = 0; i < 900; i++) begin
            $fdisplay(file_id, "%d", mem_y_2[i]);
        end
        $fclose(file_id);

        $stop();   
    end 

endmodule


module K_k_3_2 (
    input         clk,
    input  [31:0] ps_control,
    output reg [31:0] pl_status,

    input         reset_x_1,
    output [19:0] addr_x_1, // 32*32*64*4 = 262144, 需要19位宽
    input signed [31:0] data_in_x_1,
    output [31:0] data_out_x_1,
    output [3:0]  we_x_1,
    
    
    
    input         reset_x_2,
    output [19:0] addr_x_2, // 32*32*64*4 = 262144, 需要19位宽
    input signed [31:0] data_in_x_2,
    output [31:0] data_out_x_2,
    output [3:0]  we_x_2,

    input         reset_x_3,
    output [19:0] addr_x_3, // 32*32*64*4 = 262144, 需要19位宽
    input signed [31:0] data_in_x_3,
    output [31:0] data_out_x_3,
    output [3:0]  we_x_3,

    input         reset_y_1,
    input  [31:0] data_in_y_1,
    output [18:0] addr_y_1, 
    output [3:0]  we_y_1,
    output signed [31:0] final_y_1,


    input         reset_y_2,
    input  [31:0] data_in_y_2,
    output [18:0] addr_y_2, 
    output [3:0]  we_y_2,
    output signed [31:0] final_y_2,
    
    
    input         reset_w,
    input [8:0]  addr_w, // 3*3*4 = 36, 需要6位宽
    input signed [31:0] data_in_w,
    output [31:0] data_out_w,
    input [3:0]  we_w,
    input en_w_a
    );
    
    assign data_out_w = 1;

    wire [31:0] pl_status_1, pl_status_2;
    
    reg en_w_b;

    wire [6:0] addr_x_4, addr_x_5, addr_x_6;
    wire [3:0] we_x_4, we_x_5, we_x_6;
    wire [31:0] data_out_x_4, data_out_x_5, data_out_x_6;
    
    reg unsigned [6:0] mem_addr_w_1, mem_addr_w_2, mem_addr_w_3, mem_addr_w_4, mem_addr_w_5, mem_addr_w_6;
    wire  [6:0] mem_wire_addr_w_1, mem_wire_addr_w_2, mem_wire_addr_w_3, mem_wire_addr_w_4, mem_wire_addr_w_5, mem_wire_addr_w_6;
    wire [6:0] addr_w_1, addr_w_2, addr_w_3, addr_w_4, addr_w_5, addr_w_6;
    wire [3:0] we_w_1, we_w_2, we_w_3, we_w_4, we_w_5, we_w_6;
    wire signed [31:0] data_in_w_1, data_in_w_2, data_in_w_3, data_in_w_4, data_in_w_5, data_in_w_6;
    wire signed [31:0] data_out_w_1, data_out_w_2, data_out_w_3, data_out_w_4, data_out_w_5, data_out_w_6;
    reg en_w_1, en_w_2, en_w_3, en_w_4, en_w_5, en_w_6;

   
    always @(*) begin
        if (pl_status_1 == 1 && pl_status_2 == 1) begin
            pl_status = 1;
        end
        else if (pl_status_1 == 0 && pl_status_2 == 0)begin
            pl_status = 0;
        end
        else begin
            pl_status = 2;
        end
    end


    always @(*) begin
        if (en_w_a == 1) begin
            if (addr_w <= 32) begin
                mem_addr_w_1 = addr_w;
                en_w_1 = en_w_a;
                en_w_2 = 0;
                en_w_3 = 0;
                en_w_4 = 0;
                en_w_5 = 0;
                en_w_6 = 0;
            end
            else if (addr_w > 32 && addr_w <= 68) begin
                mem_addr_w_2 = addr_w - 36;
                en_w_1 = 0;
                en_w_2 = en_w_a;
                en_w_3 = 0;
                en_w_4 = 0;
                en_w_5 = 0;
                en_w_6 = 0;
            end
            else if (addr_w > 68 && addr_w <= 104) begin
                mem_addr_w_3 = addr_w - 72;
                en_w_1 = 0;
                en_w_2 = 0;
                en_w_3 = en_w_a;
                en_w_4 = 0;
                en_w_5 = 0;
                en_w_6 = 0;
            end
            else if (addr_w > 104 && addr_w <= 140) begin
                mem_addr_w_4 = addr_w - 108;
                en_w_1 = 0;
                en_w_2 = 0;
                en_w_3 = 0;
                en_w_4 = en_w_a;
                en_w_5 = 0;
                en_w_6 = 0;
            end
            else if (addr_w > 140 && addr_w <= 176) begin
                mem_addr_w_5 = addr_w - 144;
                en_w_1 = 0;
                en_w_2 = 0;
                en_w_3 = 0;
                en_w_4 = 0;
                en_w_5 = en_w_a;
                en_w_6 = 0;
            end
            else if (addr_w > 176 && addr_w <= 212) begin
                mem_addr_w_6 = addr_w - 180;
                en_w_1 = 0;
                en_w_2 = 0;
                en_w_3 = 0;
                en_w_4 = 0;
                en_w_5 = 0;
                en_w_6 = en_w_a;
            end
        end
        else begin
                en_w_1 = 0;
                en_w_2 = 0;
                en_w_3 = 0;
                en_w_4 = 0;
                en_w_5 = 0;
                en_w_6 = 0;            
        end
        
        if (ps_control == 1) begin
            en_w_b = 1;
        end
    end 
    
    assign mem_wire_addr_w_1 = mem_addr_w_1;
    assign mem_wire_addr_w_2 = mem_addr_w_2;
    assign mem_wire_addr_w_3 = mem_addr_w_3;
    assign mem_wire_addr_w_4 = mem_addr_w_4;
    assign mem_wire_addr_w_5 = mem_addr_w_5;
    assign mem_wire_addr_w_6 = mem_addr_w_6;



    K_K_3 inst1(.clk(clk), .ps_control(ps_control), .pl_status(pl_status_1), .reset_x_1(reset_x_1), .addr_x_1(addr_x_1), .data_in_x_1(data_in_x_1), .we_x_1(we_x_1), .data_out_x_1(data_out_x_1), .reset_w_1(reset_w), .addr_w_1(addr_w_1), .data_in_w_1(data_in_w_1), .data_out_w_1(data_out_w_1), .we_w_1(we_w_1),
                                                                             .reset_x_2(reset_x_2), .addr_x_2(addr_x_2), .data_in_x_2(data_in_x_2), .we_x_2(we_x_2), .data_out_x_2(data_out_x_2), .reset_w_2(reset_w), .addr_w_2(addr_w_2), .data_in_w_2(data_in_w_2), .data_out_w_2(data_out_w_2), .we_w_2(we_w_2),
                                                                             .reset_x_3(reset_x_3), .addr_x_3(addr_x_3), .data_in_x_3(data_in_x_3), .we_x_3(we_x_3), .data_out_x_3(data_out_x_3), .reset_w_3(reset_w), .addr_w_3(addr_w_3), .data_in_w_3(data_in_w_3), .data_out_w_3(data_out_w_3), .we_w_3(we_w_3),
                                                                             .reset_y(reset_y_1), .data_in_y(data_in_y_1), .addr_y(addr_y_1), .we_y(we_y_1), .final_y(final_y_1));


    K_K_3 inst2(.clk(clk), .ps_control(ps_control), .pl_status(pl_status_2), .reset_x_1(reset_x_1), .addr_x_1(addr_x_4), .data_in_x_1(data_in_x_1), .we_x_1(we_x_4), .data_out_x_1(data_out_x_4), .reset_w_1(reset_w), .addr_w_1(addr_w_4), .data_in_w_1(data_in_w_4), .data_out_w_1(data_out_w_4), .we_w_1(we_w_4),
                                                                             .reset_x_2(reset_x_2), .addr_x_2(addr_x_5), .data_in_x_2(data_in_x_2), .we_x_2(we_x_5), .data_out_x_2(data_out_x_5), .reset_w_2(reset_w), .addr_w_2(addr_w_5), .data_in_w_2(data_in_w_5), .data_out_w_2(data_out_w_5), .we_w_2(we_w_5),
                                                                             .reset_x_3(reset_x_3), .addr_x_3(addr_x_6), .data_in_x_3(data_in_x_3), .we_x_3(we_x_6), .data_out_x_3(data_out_x_6), .reset_w_3(reset_w), .addr_w_3(addr_w_6), .data_in_w_3(data_in_w_6), .data_out_w_3(data_out_w_6), .we_w_3(we_w_6),
                                                                             .reset_y(reset_y_2), .data_in_y(data_in_y_2), .addr_y(addr_y_2), .we_y(we_y_2), .final_y(final_y_2));

    

    memory mem1(.clk(clk), .ena(en_w_1), .enb(en_w_b), .wea(we_w), .addra(mem_wire_addr_w_1), .addrb(addr_w_1), .dia(data_in_w), .dob(data_in_w_1));
    memory mem2(.clk(clk), .ena(en_w_2), .enb(en_w_b), .wea(we_w), .addra(mem_wire_addr_w_2), .addrb(addr_w_2), .dia(data_in_w), .dob(data_in_w_2));
    memory mem3(.clk(clk), .ena(en_w_3), .enb(en_w_b), .wea(we_w), .addra(mem_wire_addr_w_3), .addrb(addr_w_3), .dia(data_in_w), .dob(data_in_w_3));
    memory mem4(.clk(clk), .ena(en_w_4), .enb(en_w_b), .wea(we_w), .addra(mem_wire_addr_w_4), .addrb(addr_w_4), .dia(data_in_w), .dob(data_in_w_4));
    memory mem5(.clk(clk), .ena(en_w_5), .enb(en_w_b), .wea(we_w), .addra(mem_wire_addr_w_5), .addrb(addr_w_5), .dia(data_in_w), .dob(data_in_w_5));
    memory mem6(.clk(clk), .ena(en_w_6), .enb(en_w_b), .wea(we_w), .addra(mem_wire_addr_w_6), .addrb(addr_w_6), .dia(data_in_w), .dob(data_in_w_6));
    
    

endmodule

module K_K_3 (
    input         clk,
    input  [31:0] ps_control,
    output [31:0] pl_status,
    input         reset_x_1,
    output [19:0] addr_x_1, // 32*32*64*4 = 262144, 需要19位宽
    input signed [31:0] data_in_x_1,
    output [31:0] data_out_x_1,
    output [3:0]  we_x_1,
    
    input         reset_w_1,
    output [6:0]  addr_w_1, // 3*3*4 = 36, 需要6位宽
    input signed [31:0] data_in_w_1,
    output [31:0] data_out_w_1,
    output [3:0]  we_w_1,
    
    input         reset_x_2,
    output [19:0] addr_x_2, // 32*32*64*4 = 262144, 需要19位宽
    input signed [31:0] data_in_x_2,
    output [31:0] data_out_x_2,
    output [3:0]  we_x_2,
    
    input         reset_w_2,
    output [6:0]  addr_w_2, // 3*3*4 = 36, 需要6位宽
    input signed [31:0] data_in_w_2,
    output [31:0] data_out_w_2,
    output [3:0]  we_w_2,
    
    input         reset_x_3,
    output [19:0] addr_x_3, // 32*32*64*4 = 262144, 需要19位宽
    input signed [31:0] data_in_x_3,
    output [31:0] data_out_x_3,
    output [3:0]  we_x_3,
    
    input         reset_w_3,
    output [6:0]  addr_w_3, // 3*3*4 = 36, 需要6位宽
    input signed [31:0] data_in_w_3,
    output [31:0] data_out_w_3,
    output [3:0]  we_w_3,
    
    input         reset_y,
    input  [31:0] data_in_y,
    output reg [18:0] addr_y, 
    output reg [3:0]  we_y,
    output signed [31:0] final_y
    );

    wire delay_1, delay_2, delay_3;
    reg write_done_1, write_done_2, write_done_3;
    wire signed [31:0] data_out_y_1;
    wire signed [31:0] data_out_y_2;
    wire signed [31:0] data_out_y_3;
    reg [16:0] count_y_1;
    reg [16:0] count_y_2;
    reg [16:0] count_y_3;
    wire [31:0] pl_status_1;
    wire [31:0] pl_status_2;
    wire [31:0] pl_status_3;
    wire [31:0] ps_control_1, ps_control_2, ps_control_3;
    wire signed [31:0] finall, finalll;
    wire adder_valid, adder1_out_valid, adder2_out_valid;
    
    
    
    always @(posedge clk) begin
        if (reset_x_1 == 1) begin
            count_y_1 <= 0;
            count_y_2 <= 0;
            count_y_3 <= 0;
            addr_y <= 0;
        end
        if (delay_1 == 1) begin
            we_y <= 15;
            write_done_1 <= 1;
        end
        else begin
            we_y <= 0;
            write_done_1 <= 0;
        end
        if (we_y == 15) begin
            count_y_1 <= count_y_1 + 1;
            count_y_2 <= count_y_2 + 1;
            count_y_3 <= count_y_3 + 1;
            addr_y <= addr_y + 4; // 地址++
        end 
    end

    assign finall = data_out_y_1 + data_out_y_2;
    assign finalll = finall + data_out_y_3;
    assign final_y = (finalll >= 0) ? finalll : 0 ;
    assign ps_control_1 = ps_control;
    assign ps_control_2 = ps_control;
    assign ps_control_3 = ps_control;
    assign pl_status = pl_status_1;
    assign adder_valid = 1;
    

    K_K k_k_c1(.clk(clk), .ps_control(ps_control_1), .pl_status(pl_status_1), .delay(delay_1), .count_y(count_y_1), .write_done(write_done_1), .reset_x(reset_x_1), .addr_x(addr_x_1), .data_in_x(data_in_x_1), .data_out_x(data_out_x_1), .we_x(we_x_1), 
                                                                         .reset_w(reset_w_1), .addr_w(addr_w_1), .data_in_w(data_in_w_1), .data_out_w(data_out_w_1), .we_w(we_w_1),
                                                                         .data_out_y(data_out_y_1));
    
    K_K k_k_c2(.clk(clk), .ps_control(ps_control_2), .pl_status(pl_status_2), .delay(delay_2), .count_y(count_y_2), .write_done(write_done_1), .reset_x(reset_x_2), .addr_x(addr_x_2), .data_in_x(data_in_x_2), .data_out_x(data_out_x_2), .we_x(we_x_2), 
                                                                         .reset_w(reset_w_2), .addr_w(addr_w_2), .data_in_w(data_in_w_2), .data_out_w(data_out_w_2), .we_w(we_w_2),
                                                                         .data_out_y(data_out_y_2));
    
    K_K k_k_c3(.clk(clk), .ps_control(ps_control_3), .pl_status(pl_status_3), .delay(delay_3), .count_y(count_y_3), .write_done(write_done_1), .reset_x(reset_x_3), .addr_x(addr_x_3), .data_in_x(data_in_x_3), .data_out_x(data_out_x_3), .we_x(we_x_3), 
                                                                         .reset_w(reset_w_3), .addr_w(addr_w_3), .data_in_w(data_in_w_3), .data_out_w(data_out_w_3), .we_w(we_w_3),
                                                                         .data_out_y(data_out_y_3));
                                                                         
        /*                                                                         
        add adder_1 (
                   .s_axis_a_tvalid(adder_valid),            // input wire s_axis_a_tvalid
                   .s_axis_a_tdata(data_out_y_1),              // input wire [31 : 0] s_axis_a_tdata
                   .s_axis_b_tvalid(adder_valid),            // input wire s_axis_b_tvalid
                   .s_axis_b_tdata(data_out_y_2),              // input wire [31 : 0] s_axis_b_tdata
                   .m_axis_result_tvalid(adder1_out_valid),  // output wire m_axis_result_tvalid
                   .m_axis_result_tdata(finall)    // output wire [31 : 0] m_axis_result_tdata
                 );   
        add adder_2 (
                   .s_axis_a_tvalid(adder_valid),            // input wire s_axis_a_tvalid
                   .s_axis_a_tdata(finall),              // input wire [31 : 0] s_axis_a_tdata
                   .s_axis_b_tvalid(adder_valid),            // input wire s_axis_b_tvalid
                   .s_axis_b_tdata(data_out_y_3),              // input wire [31 : 0] s_axis_b_tdata
                   .m_axis_result_tvalid(adder2_out_valid),  // output wire m_axis_result_tvalid
                   .m_axis_result_tdata(finalll)    // output wire [31 : 0] m_axis_result_tdata
                 );                                                                          
        */                                                                        
                                                                         
                                                                         
                                                                         
endmodule

module K_K (
    input         clk,
    input  [31:0] ps_control,
    output [31:0] pl_status,
    
    input         reset_x,
    output [19:0] addr_x, // 32*32*64*4 = 262144, 需要19位宽
    input signed [31:0] data_in_x,
    output [31:0] data_out_x,
    output [3:0]  we_x,

    
    input         reset_w,
    output [6:0]  addr_w, // 3*3*4 = 36, 需要6位宽
    input signed [31:0] data_in_w,
    output [31:0] data_out_w,
    output [3:0]  we_w,

    output signed [31:0] data_out_y,

    input         write_done,
    output        delay,
    input [16:0]  count_y
    );

    wire [2:0] state;


    Control  c(.clk(clk), .delay(delay), .count_y(count_y), .ps_control(ps_control), .pl_status(pl_status), .reset(reset_x), .addr_x(addr_x), .we_x(we_x), .addr_w(addr_w), .we_w(we_w), .write_done(write_done), .state(state));
    Datapath d(.clk(clk), .reset(reset_x), .data_in_x(data_in_x), .data_out_x(data_out_x), .data_in_w(data_in_w), .data_out_w(data_out_w), .data_out_y(data_out_y), .write_done(write_done), .state(state));

endmodule

module Control(
    input             clk,
    input  [31:0]     ps_control,
    output [31:0] pl_status,
    input             reset,
   
    output reg [19:0] addr_x, /* 32*32*64*4 = 262144, 需要19位宽 */
    output wire [3:0]  we_x,

    output reg [6:0]  addr_w, /* 3*3*4 = 36, 需要6位宽 */
    output wire [3:0]  we_w,

    output reg [2:0]  state,

    input             write_done, /*标志一个数组写完成*/
    output reg        delay,   /* 地址读完后延时一个周期写使能,*/
    input      [16:0] count_y      // 用于计数最后结果的个数， 30*30*64 = 57600, 16位
    );

    reg [2:0]  next_state;
    reg [4:0]  count_addr;   /* 用于计数地址， 计数9个， 0到9, 当到9时， 写使能 */

    reg [2:0]  hang, lie;       
    wire        inc;
    reg [4:0] i;

    assign inc = (next_state == 1);
    assign pl_status = (state == 3) ? 1 : 0;
    assign we_x = 0;
    assign we_w = 0;

    always @(posedge clk) begin
        if (reset == 1) begin  // 初始化一些信号
            state <= 0;
            count_addr <= 0;   
            addr_w <= 0;
            addr_x <= 0;
            hang <= 0;
            lie <= 0;
            i <= 0;
        end 
        else begin
            state <= next_state;
        end
        ///// 初始化信号结束
        /// 地址开始 ///
        if (inc == 1) begin
            count_addr <= count_addr + 1;
            ///////////  x 开始  ///////////
            if (addr_x != 4092) begin
                    if (hang == 2 && lie == 2) begin
                        if (i != 29) begin
                            addr_x <= addr_x - 2*4 - 32*4 - 31*4;
                            i <= i + 1;
                        end
                        else if (i == 29) begin
                            addr_x <= addr_x - 63 * 4;
                            i <= 0;
                        end
                        hang <= 0;
                        lie <= 0;
                    end
                    else if (lie == 2) begin
                        addr_x <= addr_x + 30*4;
                        lie <= 0;
                        hang <= hang + 1; 
                    end
                    else begin
                        addr_x <= addr_x + 4;
                        lie <= lie + 1;
                    end
            end
            ////////// x 结束 /////////////
            ////////// w 开始 /////////////
            if (addr_w <= 28) begin
                addr_w <= addr_w + 4;
            end
            else begin
                addr_w <= 0;
            end
            ////////// w 结束 /////////////
        end
        else begin
            count_addr <= 0;
        end
        /// 地址结束 ///
        /// 写开始 ///
        if (count_addr == 9) begin // 延时一个周期
            delay <= 1;
        end
        else begin
            delay <= 0;
        end
        /// 写结束 ///
    end

    // 共4个state, 0：开始，    1：地址++， 
    // 2：(等2个周期)写进bram， 3：结束
    always @(*) begin
        if (state == 0) begin
            if (ps_control == 1) begin
                next_state = 1;
            end
            else begin
                next_state = 0;
            end
        end
        else if (state == 1) begin
            if (count_addr == 9) begin
                next_state = 2;
            end
            else begin
                next_state = 1;
            end
        end
        else if (state == 2) begin
            if (write_done == 1) begin // 写完成了
                if (count_y == 899) begin  // 全写完了
                    next_state = 3;
                end
                else begin
                    next_state = 1;
                end
            end
            else begin // 还没有写完成， 继续写
                next_state = 2;
            end
        end
        else if (state == 3) begin
            if (ps_control == 1) begin
                next_state = 3;
            end
            else begin
                next_state = 0;
            end
        end 
    end
endmodule

module Datapath(
    input         clk,
    input         reset,

    input signed [31:0] data_in_x,
    output [31:0] data_out_x,

    input signed [31:0] data_in_w,
    output [31:0] data_out_w,

    output reg signed [31:0] data_out_y,

    input         write_done,
    input [2:0]   state
    );

    wire signed [31:0] multi_out, add_out;

    reg signed [31:0] multi, add, temp;
    wire              valid, valid_out_adder, valid_out_multi;
    reg signed [31:0] data_in_x_multi, data_in_w_multi;
    reg signed [31:0] data_in_a_adder, data_in_b_adder;
    
    assign data_out_w = 1;

    always @(posedge clk) begin
        if (reset == 1) begin
            temp <= 0;
            data_out_y <= 0;
        end
        if (write_done == 1) begin
            temp <= 0;
            data_out_y <= temp;
        end
        else begin
            temp <= add;
            data_out_y <= temp;
        end
    end

    always @(*) begin
        //multi = multi_out;
        //add = add_out;
        
        if (state == 1) begin
            //data_in_x_multi = data_in_x;
            //data_in_w_multi = data_in_w;
            
            //data_in_a_adder = multi;
            //data_in_b_adder = temp;
            
            multi = data_in_x *data_in_w;
            add = multi + temp;
        end
        else begin  
            //data_in_x_multi = 0;
            //data_in_w_multi = 0;
            
            //data_in_a_adder = 0;
            //data_in_b_adder = 0;            
            
            multi = 0;
            add = 0;
        end
    end
    
    assign valid = 1;    
    /*
    mult multiplier (
      //.aclk(clk),                                  // input wire aclk
      .s_axis_a_tvalid(valid),            // input wire s_axis_a_tvalid
      .s_axis_a_tdata(data_in_x_multi),              // input wire [31 : 0] s_axis_a_tdata
      .s_axis_b_tvalid(valid),            // input wire s_axis_b_tvalid
      .s_axis_b_tdata(data_in_w_multi),              // input wire [31 : 0] s_axis_b_tdata
      .m_axis_result_tvalid(valid_out_multi),  // output wire m_axis_result_tvalid
      .m_axis_result_tdata(multi_out)    // output wire [31 : 0] m_axis_result_tdata
    );
    
    add adder (
      //.aclk(clk),                                  // input wire aclk
      .s_axis_a_tvalid(valid),            // input wire s_axis_a_tvalid
      .s_axis_a_tdata(data_in_a_adder),              // input wire [31 : 0] s_axis_a_tdata
      .s_axis_b_tvalid(valid),            // input wire s_axis_b_tvalid
      .s_axis_b_tdata(data_in_b_adder),              // input wire [31 : 0] s_axis_b_tdata
      .m_axis_result_tvalid(valid_out_adder),  // output wire m_axis_result_tvalid
      .m_axis_result_tdata(add_out)    // output wire [31 : 0] m_axis_result_tdata
    );   
    */
endmodule


module memory (clk,ena,enb,wea,addra,addrb,dia,dob);
    input clk,ena,enb,wea;
    input [6:0] addra,addrb;
    input [31:0] dia;
    output [31:0] dob;
    reg [31:0] ram [8:0];
    reg [31:0] doa,dob;
    always @(posedge clk) begin
        if (ena) begin
            if (wea) begin
                ram[addra[6:2]] <= dia;
            end
        end
    end
    always @(posedge clk) begin
        if (enb) begin
            dob <= ram[addrb[6:2]];
        end
    end
endmodule
