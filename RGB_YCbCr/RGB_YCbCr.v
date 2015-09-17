/****************************************
______________                ______________
______________ \  /\  /|\  /| ______________
______________  \/  \/ | \/ | ______________
--Module Name:  RGB_YCbCr.v
--Project Name: GitHub
--Data modified: 2015-09-17 10:36:54 +0800
--author:Young-ÎâÃ÷
--E-mail: wmy367@Gmail.com
****************************************/
`timescale 1ns/1ps
module RGB_YCbCr #(
	parameter	DSIZE	= 16,
	parameter	MSIZE	= 12
)(
	input				clock  		,
	input				invsync     ,
	input				inhsync     ,
	input				inde        ,
	input [DSIZE-1:0]	inR         ,
	input [DSIZE-1:0]	inG         ,
	input [DSIZE-1:0]	inB         ,

	output				outvsync	,
	output				outhsync    ,
	output				outde       ,
	output[DSIZE-1:0]	outY        ,
	output[DSIZE-1:0]	outCb       ,
	output[DSIZE-1:0]	outCr
);


/*
Y   =  0.257*R+0.504*G+0.098*B+16 
Cb 	= -0.148*R-0.291*G+0.439*B+128
Cr  =  0.439*R-0.368*G-0.071*B+128

|Y  |    |16 |              |65.738   129.057  25.06 |  |R|
|Cb | =  |128| +  (1/256) * |-37.945  -74.494  112.43| *|G|
|Cr |    |128|              |112.439  -94.154  -18.28|  |B|

Matrix

M = 
 0.257  +0.504  +0.098
-0.148  -0.291  +0.439
 0.439  -0.368  -0.071

M * 2**12 = 
  1053        2310         401
  -606       -1192        1798
  1798       -1507        -291
*/

localparam [MSIZE-1:0]	  	M00p0_257		= 0.257 * 2**MSIZE,
							M10n0_148		= 0.148 * 2**MSIZE,
							M20p0_439       = 0.439 * 2**MSIZE;

localparam [MSIZE-1:0]		M01p0_504		= 0.504 * 2**MSIZE,
                            M11n0_291		= 0.291 * 2**MSIZE,
                            M21n0_368		= 0.368 * 2**MSIZE;

localparam [MSIZE-1:0]		M20p0_098		= 0.098 * 2**MSIZE,
                            M21p0_439		= 0.439 * 2**MSIZE,
                            M22n0_071		= 0.071 * 2**MSIZE;

reg [DSIZE+MSIZE-1:0]	Rxp0_257,Rxn0_148,Rxp0_439;

always@(posedge clock)begin
	Rxp0_257	<= inR * M00p0_257;
	Rxn0_148	<= inR * M10n0_148;
	Rxp0_439	<= inR * M20p0_439;
end

reg [DSIZE+MSIZE-1:0]	Gxp0_504,Gxn0_291,Gxn0_368;

always@(posedge clock)begin
	Gxp0_504	<= inG * M01p0_504;
	Gxn0_291	<= inG * M11n0_291;
	Gxn0_368	<= inG * M21n0_368;
end

reg [DSIZE+MSIZE-1:0]	Bxp0_098,Bxp0_439,Bxn0_071;

always@(posedge clock)begin
	Bxp0_098	<= inB * M20p0_098;
	Bxp0_439	<= inB * M21p0_439;
	Bxn0_071	<= inB * M22n0_071;
end

reg [DSIZE-1:0]	Rxp0_257__Gxp0_504;
reg [DSIZE-1:0]	Rxn0_148__Gxn0_291;
reg [DSIZE-1:0]	Gxn0_368__Bxn0_071;

reg [DSIZE-1:0]	Bxp0_098__16;
reg [DSIZE-1:0]	Bxp0_439__128;
reg [DSIZE-1:0]	Rxp0_439__128;

always@(posedge clock)begin
	Rxp0_257__Gxp0_504	<= Rxp0_257[DSIZE+MSIZE-1-:DSIZE] + Gxp0_504[DSIZE+MSIZE-1-:DSIZE];
	Rxn0_148__Gxn0_291	<= Rxn0_148[DSIZE+MSIZE-1-:DSIZE] + Gxn0_291[DSIZE+MSIZE-1-:DSIZE];
	Gxn0_368__Bxn0_071	<= Gxn0_368[DSIZE+MSIZE-1-:DSIZE] + Bxn0_071[DSIZE+MSIZE-1-:DSIZE];

	Bxp0_098__16		<= Bxp0_098[DSIZE+MSIZE-1-:DSIZE] + (2**DSIZE)/16;
	Bxp0_439__128		<= Bxp0_439[DSIZE+MSIZE-1-:DSIZE] + (2**DSIZE)/2;
	Rxp0_439__128		<= Rxp0_439[DSIZE+MSIZE-1-:DSIZE] + (2**DSIZE)/2;
end

reg [DSIZE-1:0]	Rxp0_257__Gxp0_504___Bxp0_098__16;
reg [DSIZE-1:0]	Rxn0_148__Gxn0_291___Bxp0_439__128;
reg [DSIZE-1:0]	Gxn0_368__Bxn0_071___Rxp0_439__128;

always@(posedge clock)begin
	Rxp0_257__Gxp0_504___Bxp0_098__16	<= Rxp0_257__Gxp0_504 	+ Bxp0_098__16;
	Rxn0_148__Gxn0_291___Bxp0_439__128	<= Bxp0_439__128		- Rxn0_148__Gxn0_291;
	Gxn0_368__Bxn0_071___Rxp0_439__128	<= Rxp0_439__128		- Gxn0_368__Bxn0_071;
end    


assign	outY  		=  Rxp0_257__Gxp0_504___Bxp0_098__16; 
assign	outCb       =  Rxn0_148__Gxn0_291___Bxp0_439__128;
assign	outCr       =  Gxn0_368__Bxn0_071___Rxp0_439__128; 

latency #(
	.LAT		(3),
	.DSIZE		(3)
)lat_sync(
	.clk		(clock						),
	.rst_n		(1'b1						),
	.d			({invsync,inhsync,inde}		),
	.q			({outvsync,outhsync,outde}	)
);

endmodule



