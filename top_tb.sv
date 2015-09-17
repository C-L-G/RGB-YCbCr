/****************************************
______________                ______________
______________ \  /\  /|\  /| ______________
______________  \/  \/ | \/ | ______________
--Module Name:  top_tb.sv
--Project Name: GitHub
--Data modified: 2015-09-17 10:36:54 +0800
--author:Young-ÎâÃ÷
--E-mail: wmy367@Gmail.com
****************************************/
`timescale 1ns/1ps
module top_tb;

bit		clock;

clock_rst clk_c0(
	.clock		(clock),
	.rst		(rst_n)
);

defparam clk_c0.ACTIVE = 0;
initial begin:INITIAL_CLOCK
	clk_c0.run(10 , 1000/100 ,0);		//100	
end

localparam	DSIZE	= 16,
			MSIZE	= 12;

logic[DSIZE-1:0]				rdata,gdata,bdata;
logic	unsigned[DSIZE-1:0]		ydata;
logic	unsigned[DSIZE-1:0]		cbdata;
logic	unsigned[DSIZE-1:0]		crdata;


RGB_YCbCr #(
	.DSIZE			(DSIZE		),
	.MSIZE			(MSIZE		)
)RGB_YCbCr_inst(
/*	input				*/.clock  		(clock			),
/*	input				*/.invsync   	(1'b1           ),
/*	input				*/.inhsync   	(1'b1           ),
/*	input				*/.inde      	(1'b1           ),
/*	input [DSIZE-1:0]	*/.inR       	(rdata          ),
/*	inout [DSIZE-1:0]	*/.inG       	(gdata          ),
/*	input [DSIZE-1:0]	*/.inB       	(bdata          ),

/*	output				*/.outvsync		(         		),
/*	output				*/.outhsync  	(               ),
/*	output				*/.outde     	(               ),
/*	output[DSIZE-1:0]	*/.outY      	(ydata          ),
/*	output[DSIZE-1:0]	*/.outCb     	(cbdata         ),
/*	output[DSIZE-1:0]	*/.outCr     	(crdata         )
);

real Y_cal;
int unsigned Y_m;
real Cb_cal;
int Cb_m;
real Cr_cal;
int Cr_m;
logic [2:0]		cnt = 3'b000;

always@(posedge clock)begin:DATA_BLOCK
	cnt = cnt + 1;	
//	rdata		= $urandom_range(0,16'hFFFF);
//    gdata		= $urandom_range(0,16'hFFFF);
//    bdata		= $urandom_range(0,16'hFFFF);
	rdata		= cnt[2]?	16'hFF_FF	: 16'h00_00;
    gdata		= cnt[1]?	16'hFF_FF	: 16'h00_00;
    bdata		= cnt[0]?	16'hFF_FF	: 16'h00_00;
	
//	rdata		= 16'h00_00;
//    gdata		= 16'hFF_FF;
//    bdata		= 16'h00_00;
end

logic[DSIZE-1:0]		R,G,B;
cross_clk_sync #(                     
	.DSIZE    	(DSIZE*3),                 
	.LAT		(3)                   
)latency_data(                              
	clock,                              
	1'b1,                            
	{rdata,gdata,bdata},
	{R,G,B}
);       

always@(R,G,B)begin
	Y_cal		=  0.257*R+0.504*G+0.098*B+(2**DSIZE)/16 	;
	Cb_cal		= -0.148*R-0.291*G+0.439*B+(2**DSIZE)/2  ;
	Cr_cal		=  0.439*R-0.368*G-0.071*B+(2**DSIZE)/2  ;
end

always@(ydata,cbdata,crdata)begin
	Y_m		= ydata*1	;
    Cb_m    = cbdata*1	;
	Cr_m    = crdata*1	;
end


//----->> TEST YCbCr to RGB <<-------------------

logic [DSIZE-1:0]		outr;
logic [DSIZE-1:0]		outg;
logic [DSIZE-1:0]		outb;

YCbCr_RGB #(
	.DSIZE			(DSIZE		),
	.MSIZE			(MSIZE		)
)YCbCr_RGB_inst(
/*	input				*/.clock  		(clock			),
/*	input				*/.invsync   	(1'b1           ),
/*	input				*/.inhsync   	(1'b1           ),
/*	input				*/.inde      	(1'b1           ),
/*	input [DSIZE-1:0]	*/.inY       	(ydata          ),
/*	inout [DSIZE-1:0]	*/.inCb       	(cbdata         ),
/*	input [DSIZE-1:0]	*/.inCr       	(crdata         ),

/*	output				*/.outvsync		(         ),
/*	output				*/.outhsync  	(         ),
/*	output				*/.outde     	(         ),
/*	output[DSIZE-1:0]	*/.outR      	(outr          	),
/*	output[DSIZE-1:0]	*/.outG     	(outg          	),
/*	output[DSIZE-1:0]	*/.outB     	(outb          	)
);

real 			R_cal;
int unsigned 	R_m;
real 			G_cal;
int 			G_m;
real 			B_cal;
int 			B_m;


logic[DSIZE-1:0]		y_lat,cb_lat,cr_lat;
cross_clk_sync #(                     
	.DSIZE    	(DSIZE*3),                 
	.LAT		(4)                   
)latency_ydata(                              
	clock,                              
	1'b1,                            
	{ydata,cbdata,crdata},
	{y_lat,cb_lat,cr_lat}
);      
 
real	y_1_164;
real	cr_1_596;
real	cb_0_392;
real	cb_2_017;
real	cr_0_813;


always@(y_lat,cb_lat,cr_lat)begin
	y_1_164 = 1.164 * (real'(y_lat)- real'(2**(DSIZE-4)));
	cb_0_392= 0.392 * (real'(cb_lat)-real'(2**(DSIZE-1)));
	cr_1_596= 1.596 * (real'(cr_lat)-real'(2**(DSIZE-1)));
	cb_2_017= 2.017 * (real'(cb_lat)-real'(2**(DSIZE-1)));
	cr_0_813= 0.813 * (real'(cr_lat)-real'(2**(DSIZE-1)));
	R_cal		= y_1_164+cr_1_596;           
	G_cal		= y_1_164-cb_0_392-cr_0_813;
	B_cal		= y_1_164+cb_2_017;             
end

always@(outr,outg,outb)begin
	R_m	= outr*1	;
    G_m = outg*1	;
	B_m = outb*1	;
end

//-----<< TEST YCbCr to RGB >>-------------------

always@(negedge clock)begin:COUNT
int		II;
	$display("-------------->> %5d  <<---------",II);
	$display("Y : Model--> %16d ; cal--> %10.6f ",Y_m,Y_cal);
	$display("Cb: Model--> %16d ; cal--> %10.6f ",Cb_m,Cb_cal);
	$display("Cr: Model--> %16d ; cal--> %10.6f ",Cr_m,Cr_cal);
	$display("==========================================");
	$display("R : Model--> %16d ; cal--> %10.6f ",R_m,R_cal);
	$display("G : Model--> %16d ; cal--> %10.6f ",G_m,G_cal);
	$display("B : Model--> %16d ; cal--> %10.6f ",B_m,B_cal);
	$display("----------------------------------");
	II += 1;
end

endmodule
