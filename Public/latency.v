/****************************************
______________                ______________
______________ \  /\  /|\  /| ______________
______________  \/  \/ | \/ | ______________
--Module Name:  latency.v
--Project Name: GitHub
--Data modified: 2015-09-17 10:55:13 +0800
--author:Young-ÎâÃ÷
--E-mail: wmy367@Gmail.com
****************************************/
`timescale 1ns/1ps
module latency #(
	parameter	LAT		= 2,
	parameter	DSIZE	= 1
)(
	input					clk,
	input					rst_n,
	input [DSIZE-1:0]		d,
	output[DSIZE-1:0]		q
);

reg	[DSIZE-1:0]		ltc		[LAT-1:0];

always@(posedge clk,negedge rst_n)begin:GEN_LAT
integer II;
	if(~rst_n)begin
		for(II=0;II<LAT;II=II+1)
			ltc[II]		<= {DSIZE{1'b0}};
	end else begin
		ltc[0]	<= d;
		for(II=1;II<LAT;II=II+1)
			ltc[II]		<= ltc[II-1];
end end

assign	q	= ltc[LAT-1];

endmodule
