// -----------------------------------------------------------------------------
// Copyright (c) 2014-2022 All rights reserved
// -----------------------------------------------------------------------------
// Author : 1598491517@qq.com
// File   : Handshakes_delay_Valid_Data.v
// Create : 2022-06-09 15:37:03
// Revise : 2022-06-09 22:04:31
// Editor : sublime text3, tab size (4)
// -----------------------------------------------------------------------------

module Handshakes_delay_Valid_Data #
(
	parameter	WORD_WIDTH = 32

)
(
	input	wire						clk,
	input	wire						rst_n,
	input	wire						up_valid,
	input	wire	[WORD_WIDTH-1:0]	up_data,
	input	wire						down_ready,
	output	wire						down_valid,
	output	wire	[WORD_WIDTH-1:0]	down_data,
	output	wire						up_ready
);

reg						buf_valid;
reg	[WORD_WIDTH-1:0]	buf_data;
wire					back_ready;

//把输入的有效信号用寄存器缓存起来
always@(posedge clk)begin
	if (!rst_n) begin
		buf_valid <= 1'b0;
	end
	else if (up_valid == 1'b1)begin
		buf_valid <= 1'b1;
	end
	else if (down_ready == 1'b1)begin
		buf_valid <= 1'b0;
	end
	else begin
		buf_valid <= buf_valid;
	end
end

//输入端与寄存器建立了握手之后，就可以传新值
always@(posedge clk)begin
	if (!rst_n)begin
		buf_data <= 'd0;
	end
	else if ((back_ready == 1'b1) && (up_valid == 1'b1))begin 
		buf_data <= up_data;
	end
	else begin
		buf_data <= buf_data;
	end
end
//写值end

//寄存器的ready信号，表示寄存器处理完了的上一个值，可以接受新值
//1.down_ready==1,此时若寄存器存有上一拍的值，必然会因为buf_valid==1且down_ready==1而在下一拍读出此值，所以可以直接在下一拍存入新的up_data避免气泡
//2.buf_valid == 1'b0，这就表示缓存的寄存器没有有效数据，可以放心覆盖新值
assign back_ready = (down_ready == 1'b1)|(buf_valid == 1'b0);

assign down_valid = buf_valid;
assign down_data = buf_data;
assign up_ready = back_ready;

endmodule