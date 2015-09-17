/****************************************
______________                ______________
______________ \  /\  /|\  /| ______________
______________  \/  \/ | \/ | ______________
--Module Name:  YCbCr_RGB.v
--Project Name: GitHub
--Data modified: 2015-09-17 10:55:13 +0800
--author:Young-ÎâÃ÷
--E-mail: wmy367@Gmail.com
****************************************/
`timescale 1ns/1ps
module YCbCr_RGB #(
	parameter	DSIZE	= 16,
	parameter	MSIZE	= 12
)(
	input				clock  		,
	input				invsync     ,
	input				inhsync     ,
	input				inde        ,
	input [DSIZE-1:0]	inY         ,
	input [DSIZE-1:0]	inCb        ,
	input [DSIZE-1:0]	inCr        ,

	output				outvsync	,
	output				outhsync    ,
	output				outde       ,
	output[DSIZE-1:0]	outR        ,
	output[DSIZE-1:0]	outG        ,
	output[DSIZE-1:0]	outB
);

/*
R = 1.164*(Y-16)+1.596*(Cr-128)
G = 1.164*(Y-16)-0.392*(Cb-128)-0.813*(Cr-128)
B = 1.164*(Y-16)+2.017*(Cb-128)

R = 1.164*Y + 1.596*Cr - 222.912
G = 1.164*Y - 0.392*Cb - 0.813*Cr +135.616
B = 1.164*Y + 2.017*Cb - 276.800

*/

localparam [MSIZE+1:0]	Mp1_164		= 1.164		* 2**MSIZE	,
						Mp1_596 	= 1.596		* 2**MSIZE	,
						Mn0_392		= 0.392		* 2**MSIZE  ,
						Mn0_813		= 0.813		* 2**MSIZE  ,
						Mp2_017		= 2.017		* 2**MSIZE  ;

localparam [DSIZE-1:0]	Mn222_912	= 222.912	* 2**(DSIZE-8)	,
						Mp135_616	= 135.616	* 2**(DSIZE-8)  ;
localparam [DSIZE:0]	Mn276_800	= 276.800	* 2**(DSIZE-8) 	;

reg [DSIZE+MSIZE-1:0]	Yp1_164;
reg [DSIZE+MSIZE-1:0]	Crp1_596;
reg [DSIZE+MSIZE-1:0]	Crn0_813;
reg [DSIZE+MSIZE-1:0]	Cbn0_392;
reg [DSIZE+MSIZE-1:0]	Cbp2_017;

always@(posedge clock)begin
	Yp1_164		<= inY	* Mp1_164[MSIZE:1];
	Crp1_596	<= inCr	* Mp1_596[MSIZE:1];
	Crn0_813	<= inCr	* Mn0_813[MSIZE-1:0];
	Cbn0_392	<= inCb	* Mn0_392[MSIZE-1:0];
	Cbp2_017	<= inCb	* Mp2_017[MSIZE+1:2];
end

reg [DSIZE+1:0]	Yp1_164__Crp1_596;
reg [DSIZE:0]	Yp1_164__Mp135_616;
reg [DSIZE:0]	Cbn0_392__Crn0_813;
reg [DSIZE+1:0]	Yp1_164__Cbp2_017;

always@(posedge clock)begin
	Yp1_164__Crp1_596	<= Yp1_164[DSIZE+MSIZE-1-:(DSIZE+1)] + Crp1_596[DSIZE+MSIZE-1-:(DSIZE+1)];
	Yp1_164__Mp135_616	<= Yp1_164[DSIZE+MSIZE-1-:(DSIZE+1)] + Mp135_616;
	Cbn0_392__Crn0_813	<= Cbn0_392[DSIZE+MSIZE-1-:DSIZE]+ Crn0_813[DSIZE+MSIZE-1-:DSIZE];
	Yp1_164__Cbp2_017	<= Yp1_164[DSIZE+MSIZE-1-:(DSIZE+1)] + Cbp2_017[DSIZE+MSIZE-1-:(DSIZE+2)]; 
end

reg [DSIZE+1:0]	Yp1_164__Crp1_596__Mn222_912;
reg [DSIZE+1:0]	Yp1_164__Mp135_616___Cbn0_392__Crn0_813;
reg [DSIZE+1:0]	Yp1_164__Cbp2_017__Mn276_800;

always@(posedge clock)begin
	Yp1_164__Crp1_596__Mn222_912			<= Yp1_164__Crp1_596 	- Mn222_912;
	Yp1_164__Mp135_616___Cbn0_392__Crn0_813	<= Yp1_164__Mp135_616 	- Cbn0_392__Crn0_813;
	Yp1_164__Cbp2_017__Mn276_800			<= Yp1_164__Cbp2_017	- Mn276_800; 
end

reg [DSIZE-1:0]	R_reg,G_reg,B_reg;

always@(posedge clock)
	if(Yp1_164__Crp1_596__Mn222_912[DSIZE+1])
			R_reg	<=		{DSIZE{1'b0}};
	else if(Yp1_164__Crp1_596__Mn222_912[DSIZE])
			R_reg	<= 		{DSIZE{1'b1}};
	else	R_reg	<= 		Yp1_164__Crp1_596__Mn222_912[DSIZE-1:0];

always@(posedge clock)
	if(Yp1_164__Mp135_616___Cbn0_392__Crn0_813[DSIZE+1])
			G_reg	<=		{DSIZE{1'b0}};
	else if(Yp1_164__Mp135_616___Cbn0_392__Crn0_813[DSIZE])
			G_reg	<= 		{DSIZE{1'b1}};
	else	G_reg	<= 		Yp1_164__Mp135_616___Cbn0_392__Crn0_813[DSIZE-1:0];

always@(posedge clock)
	if(Yp1_164__Cbp2_017__Mn276_800[DSIZE+1])
			B_reg	<=		{DSIZE{1'b0}};
	else if(Yp1_164__Cbp2_017__Mn276_800[DSIZE])
			B_reg	<= 		{DSIZE{1'b1}};
	else	B_reg	<= 		Yp1_164__Cbp2_017__Mn276_800[DSIZE-1:0];


assign	 outR		=  R_reg	;
assign   outG		=  G_reg	;
assign   outB		=  B_reg	;


latency #(
	.LAT		(4),
	.DSIZE		(3)
)lat_sync(
	.clk		(clock						),
	.rst_n		(1'b1						),
	.d			({invsync,inhsync,inde}		),
	.q			({outvsync,outhsync,outde}	)
);


endmodule

