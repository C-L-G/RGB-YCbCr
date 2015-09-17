/****************************************
______________                ______________
______________ \  /\  /|\  /| ______________
______________  \/  \/ | \/ | ______________
--Module Name:  clock_rst.sv
--Project Name: GitHub
--Data modified: 2015-09-17 10:55:13 +0800
--author:Young-ÎâÃ÷
--E-mail: wmy367@Gmail.com
****************************************/
`timescale 1ns/1ps
module clock_rst(
	output	bit clock,
	output	bit rst
);

parameter bit	ACTIVE	= 1;

int		clk_i	= 0;
int		rst_i	= 0;
longint		period_cnt	= 0;
bit		clk_pause	= 1;
int		rst_hold	= 10;
real		clk_period	= 5;

task run(
input int		reset_hold	= 10,
input real		period		= 5,
input longint		period_count	= 0
);
begin
	clk_pause	= 1;
	clk_i		= 0;
	rst_i		= 0;
	rst		= ACTIVE;
	rst_hold	= reset_hold;
	clk_period	= period/2;
	period_cnt	= period_count;
//	$stop;
	repeat(3)	#(period*3);
	clk_pause	= 0;
	repeat(rst_hold)	@(posedge clock);
	rst		= !ACTIVE;
end
endtask

always #clk_period begin
	if(clk_pause == 0 && (period_cnt == 0 || clk_i<period_cnt))begin
		clock	= ~clock;
	end else begin
		clock	=  clock;
	end
end


endmodule
