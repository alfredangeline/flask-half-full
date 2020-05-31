`timescale 1ns / 1ps

// nexysA7fpga.v - Top level module for the Nexys A7 version of the ECE 544 Getting Started project
//
// Created By:	Roy Kravitz
// Date:		30-March-2020
// Version:		1.0
//
// Description:
// ------------
// This module provides the top level for the Getting Started hardware.
// The module assume that a HB3 is in JD and an encoder is in JC.
//////////////////////////////////////////////////////////////////////
module nexysA7fpga(
    input				clk,			// 100Mhz clock input
    input				btnC,			// center pushbutton
    input				btnU,			// UP (North) pusbhbutton
    input				btnL,			// LEFT (West) pushbutton
    input				btnD,			// DOWN (South) pushbutton  - used for system reset
    input				btnR,			// RIGHT (East) pushbutton
	input				btnCpuReset,	// CPU reset pushbutton
    output [12:0]ddr2_sdram_addr,
    output [2:0]ddr2_sdram_ba,
    output ddr2_sdram_cas_n,
    output [0:0]ddr2_sdram_ck_n,
    output [0:0]ddr2_sdram_ck_p,
    output [0:0]ddr2_sdram_cke,
    output [0:0]ddr2_sdram_cs_n,
    output [1:0]ddr2_sdram_dm,
    inout [15:0]ddr2_sdram_dq,
    inout [1:0]ddr2_sdram_dqs_n,
    inout [1:0]ddr2_sdram_dqs_p,
    output [0:0]ddr2_sdram_odt,
    output ddr2_sdram_ras_n,
    output ddr2_sdram_we_n,
    input	[15:0]		sw,				// slide switches on Nexys 4
    output	[15:0] 		led,			// LEDs on Nexys 4   
    output              RGB1_Blue,      // RGB1 LED (LD16) 
    output              RGB1_Green,
    output              RGB1_Red,
    output              RGB2_Blue,      // RGB2 LED (LD17)
    output              RGB2_Green,
    output              RGB2_Red,
    output [7:0]        an,             // Seven Segment display
    output [6:0]        seg,
    output              dp,             // decimal point display on the seven segment 
	output  [3:0]       JA_O,            // JA Output Pmod conector - Used for debugging purposes
    input  [3:0]       JA_I,           // JA Inpout Pmod conector - Used for debugging purposes
    inout	[7:0] 		JB,				// JB Pmod connector - PmodOLEDrgb
    inout	[7:0] 		JC				// JC Pmod connector - PmodEnc signals
);

// internal variables
// Clock and Reset 
wire				sysclk;             // 
wire				sysreset_n, sysreset;

wire UART_0_rxd_w;
wire UART_0_txd_w;

// Rotary encoder pins
wire 				Pmod_out_0_pin1_i, Pmod_out_0_pin1_io, Pmod_out_0_pin1_o, Pmod_out_0_pin1_t;
wire 				Pmod_out_0_pin2_i, Pmod_out_0_pin2_io, Pmod_out_0_pin2_o, Pmod_out_0_pin2_t;
wire 				Pmod_out_0_pin3_i, Pmod_out_0_pin3_io, Pmod_out_0_pin3_o, Pmod_out_0_pin3_t;
wire 				Pmod_out_0_pin4_i, Pmod_out_0_pin4_io, Pmod_out_0_pin4_o, Pmod_out_0_pin4_t;
wire 				Pmod_out_0_pin7_i, Pmod_out_0_pin7_io, Pmod_out_0_pin7_o, Pmod_out_0_pin7_t; 
wire 				Pmod_out_0_pin8_i, Pmod_out_0_pin8_io, Pmod_out_0_pin8_o, Pmod_out_0_pin8_t; 
wire 				Pmod_out_0_pin9_i, Pmod_out_0_pin9_io, Pmod_out_0_pin9_o, Pmod_out_0_pin9_t;
wire 				Pmod_out_0_pin10_i,Pmod_out_0_pin10_io, Pmod_out_0_pin10_o, Pmod_out_0_pin10_t;

// OLED pins 
wire 				pmodoledrgb_out_pin1_i, pmodoledrgb_out_pin1_io, pmodoledrgb_out_pin1_o, pmodoledrgb_out_pin1_t; 
wire 				pmodoledrgb_out_pin2_i, pmodoledrgb_out_pin2_io, pmodoledrgb_out_pin2_o, pmodoledrgb_out_pin2_t; 
wire 				pmodoledrgb_out_pin3_i, pmodoledrgb_out_pin3_io, pmodoledrgb_out_pin3_o, pmodoledrgb_out_pin3_t; 
wire 				pmodoledrgb_out_pin4_i, pmodoledrgb_out_pin4_io, pmodoledrgb_out_pin4_o, pmodoledrgb_out_pin4_t; 
wire 				pmodoledrgb_out_pin7_i, pmodoledrgb_out_pin7_io, pmodoledrgb_out_pin7_o, pmodoledrgb_out_pin7_t; 
wire 				pmodoledrgb_out_pin8_i, pmodoledrgb_out_pin8_io, pmodoledrgb_out_pin8_o, pmodoledrgb_out_pin8_t; 
wire 				pmodoledrgb_out_pin9_i, pmodoledrgb_out_pin9_io, pmodoledrgb_out_pin9_o, pmodoledrgb_out_pin9_t; 
wire 				pmodoledrgb_out_pin10_i, pmodoledrgb_out_pin10_io, pmodoledrgb_out_pin10_o, pmodoledrgb_out_pin10_t;

// GPIO pins 
wire	[7:0]	    gpio_in;				// embsys GPIO input port
wire	[7:0]	    gpio_out;				// embsys GPIO output port

//DDR
wire [12:0]ddr2_sdram_addr;
wire [2:0]ddr2_sdram_ba;
wire ddr2_sdram_cas_n;
wire [0:0]ddr2_sdram_ck_n;
wire [0:0]ddr2_sdram_ck_p;
wire [0:0]ddr2_sdram_cke;
wire [0:0]ddr2_sdram_cs_n;
wire [1:0]ddr2_sdram_dm;
wire [15:0]ddr2_sdram_dq;
wire [1:0]ddr2_sdram_dqs_n;
wire [1:0]ddr2_sdram_dqs_p;
wire [0:0]ddr2_sdram_odt;
wire ddr2_sdram_ras_n;
wire ddr2_sdram_we_n;

// Pmod OLED connections 
assign JB[0] = pmodoledrgb_out_pin1_io;
assign JB[1] = pmodoledrgb_out_pin2_io;
assign JB[2] = pmodoledrgb_out_pin3_io;
assign JB[3] = pmodoledrgb_out_pin4_io;
assign JB[4] = pmodoledrgb_out_pin7_io;
assign JB[5] = pmodoledrgb_out_pin8_io;
assign JB[6] = pmodoledrgb_out_pin9_io;
assign JB[7] = pmodoledrgb_out_pin10_io;

// RGB LED 
wire                w_RGB1_Red, w_RGB1_Blue, w_RGB1_Green;
// plug the output of the RGB LEDs into the PWM Detection Module
assign RGB1_Blue = w_RGB1_Blue;
assign RGB1_Green = w_RGB1_Green;
assign RGB1_Red = w_RGB1_Red;

// LED pins 
wire    [15:0]      led_int;                // Nexys4IO drives these outputs

// make the connections to the GPIO port.  Most of the bits are unused in the Getting
// Started project but GPIO's provide a convenient way to get the inputs and
// outputs from logic you create to and from the Microblaze.  For example,
// you may decide that using an axi_gpio peripheral is a good way to interface
// your hardware pulse-width detect logic with the Microblaze.  Our application
// is simple.
// Wrap the RGB led output back to the application program for software pulse-width detect
assign gpio_in = {5'b00000, w_RGB1_Red, w_RGB1_Blue, w_RGB1_Green};

// Drive the leds from the signal generated by the microblaze 
assign led = led_int;                   // LEDs are driven by led

// make the connections
// system-wide signals
assign sysclk = clk;
assign sysreset_n = btnCpuReset;		// The CPU reset pushbutton is asserted low.  The other pushbuttons are asserted high
										// but the Microblaze for Nexys 4 expects reset to be asserted low
assign sysreset = ~sysreset_n;			// Generate a reset signal that is asserted high for any logic blocks expecting it.

// JA and JD connectors can be used for debug purposes
assign JA_O[0] = clk;
assign JA_O[1] = 1'b0;
assign JA_O[2] = UART_0_txd_w;
assign JA_O[3] = 1'b0;
assign JA_I[0] = UART_0_rxd_w;

// PmodENC signals
// JC - top row
// Pins are assigned such that turning the knob to the right
// causes the rotary count to increment.
assign  Pmod_out_0_pin1_io = JC[0];
assign  Pmod_out_0_pin2_io = JC[1];
assign  Pmod_out_0_pin3_io = JC[2];
assign  Pmod_out_0_pin4_io = JC[3];
assign  Pmod_out_0_pin7_io = JC[4];
assign  Pmod_out_0_pin8_io = JC[5];
assign  Pmod_out_0_pin9_io = JC[6];
assign  Pmod_out_0_pin10_io = JC[7];

// instantiate the embedded system
embsys EMBSYS
       (// PMOD OLED pins 
        .PmodOLEDrgb_out_0_pin10_i(pmodoledrgb_out_pin10_i),
	    .PmodOLEDrgb_out_0_pin10_o(pmodoledrgb_out_pin10_o),
	    .PmodOLEDrgb_out_0_pin10_t(pmodoledrgb_out_pin10_t),
	    .PmodOLEDrgb_out_0_pin1_i(pmodoledrgb_out_pin1_i),
	    .PmodOLEDrgb_out_0_pin1_o(pmodoledrgb_out_pin1_o),
	    .PmodOLEDrgb_out_0_pin1_t(pmodoledrgb_out_pin1_t),
	    .PmodOLEDrgb_out_0_pin2_i(pmodoledrgb_out_pin2_i),
	    .PmodOLEDrgb_out_0_pin2_o(pmodoledrgb_out_pin2_o),
	    .PmodOLEDrgb_out_0_pin2_t(pmodoledrgb_out_pin2_t),
	    .PmodOLEDrgb_out_0_pin3_i(pmodoledrgb_out_pin3_i),
	    .PmodOLEDrgb_out_0_pin3_o(pmodoledrgb_out_pin3_o),
	    .PmodOLEDrgb_out_0_pin3_t(pmodoledrgb_out_pin3_t),
	    .PmodOLEDrgb_out_0_pin4_i(pmodoledrgb_out_pin4_i),
	    .PmodOLEDrgb_out_0_pin4_o(pmodoledrgb_out_pin4_o),
	    .PmodOLEDrgb_out_0_pin4_t(pmodoledrgb_out_pin4_t),
	    .PmodOLEDrgb_out_0_pin7_i(pmodoledrgb_out_pin7_i),
	    .PmodOLEDrgb_out_0_pin7_o(pmodoledrgb_out_pin7_o),
	    .PmodOLEDrgb_out_0_pin7_t(pmodoledrgb_out_pin7_t),
	    .PmodOLEDrgb_out_0_pin8_i(pmodoledrgb_out_pin8_i),
	    .PmodOLEDrgb_out_0_pin8_o(pmodoledrgb_out_pin8_o),
	    .PmodOLEDrgb_out_0_pin8_t(pmodoledrgb_out_pin8_t),
	    .PmodOLEDrgb_out_0_pin9_i(pmodoledrgb_out_pin9_i),
	    .PmodOLEDrgb_out_0_pin9_o(pmodoledrgb_out_pin9_o),
	    .PmodOLEDrgb_out_0_pin9_t(pmodoledrgb_out_pin9_t),
	    //UART
	    .UART_0_rxd(UART_0_rxd_w),
        .UART_0_txd(UART_0_txd_w),
	    // GPIO pins 
        .gpio_rtl_0_tri_i(gpio_in),
        .gpio_rtl_1_tri_o(gpio_out),
        //DDR
        .ddr2_sdram_addr(ddr2_sdram_addr),
        .ddr2_sdram_ba(ddr2_sdram_ba),
        .ddr2_sdram_cas_n(ddr2_sdram_cas_n),
        .ddr2_sdram_ck_n(ddr2_sdram_ck_n),
        .ddr2_sdram_ck_p(ddr2_sdram_ck_p),
        .ddr2_sdram_cke(ddr2_sdram_cke),
        .ddr2_sdram_cs_n(ddr2_sdram_cs_n),
        .ddr2_sdram_dm(ddr2_sdram_dm),
        .ddr2_sdram_dq(ddr2_sdram_dq),
        .ddr2_sdram_dqs_n(ddr2_sdram_dqs_n),
        .ddr2_sdram_dqs_p(ddr2_sdram_dqs_p),
        .ddr2_sdram_odt(ddr2_sdram_odt),
        .ddr2_sdram_ras_n(ddr2_sdram_ras_n),
        .ddr2_sdram_we_n(ddr2_sdram_we_n),
        // Pmod Rotary Encoder
	    .Pmod_out_0_pin10_i(Pmod_out_0_pin10_i),
        .Pmod_out_0_pin10_o(Pmod_out_0_pin10_o),
        .Pmod_out_0_pin10_t(Pmod_out_0_pin10_t),
        .Pmod_out_0_pin1_i(Pmod_out_0_pin1_i),
        .Pmod_out_0_pin1_o(Pmod_out_0_pin1_o),
        .Pmod_out_0_pin1_t(Pmod_out_0_pin1_t),
        .Pmod_out_0_pin2_i(Pmod_out_0_pin2_i),
        .Pmod_out_0_pin2_o(Pmod_out_0_pin2_o),
        .Pmod_out_0_pin2_t(Pmod_out_0_pin2_t),
        .Pmod_out_0_pin3_i(Pmod_out_0_pin3_i),
        .Pmod_out_0_pin3_o(Pmod_out_0_pin3_o),
        .Pmod_out_0_pin3_t(Pmod_out_0_pin3_t),
        .Pmod_out_0_pin4_i(Pmod_out_0_pin4_i),
        .Pmod_out_0_pin4_o(Pmod_out_0_pin4_o),
        .Pmod_out_0_pin4_t(Pmod_out_0_pin4_t),
        .Pmod_out_0_pin7_i(Pmod_out_0_pin7_i),
        .Pmod_out_0_pin7_o(Pmod_out_0_pin7_o),
        .Pmod_out_0_pin7_t(Pmod_out_0_pin7_t),
        .Pmod_out_0_pin8_i(Pmod_out_0_pin8_i),
        .Pmod_out_0_pin8_o(Pmod_out_0_pin8_o),
        .Pmod_out_0_pin8_t(Pmod_out_0_pin8_t),
        .Pmod_out_0_pin9_i(Pmod_out_0_pin9_i),
        .Pmod_out_0_pin9_o(Pmod_out_0_pin9_o),
        .Pmod_out_0_pin9_t(Pmod_out_0_pin9_t),
        // RGB1/2 Led's 
        .RGB1_Blue_0(w_RGB1_Blue),
        .RGB1_Green_0(w_RGB1_Green),
        .RGB1_Red_0(w_RGB1_Red),
        .RGB2_Blue_0(RGB2_Blue),
        .RGB2_Green_0(RGB2_Green),
        .RGB2_Red_0(RGB2_Red),
        // Seven Segment Display anode control  
        .an_0(an),
        .dp_0(dp),
        .led_0(led_int),
        .seg_0(seg),
        // Push buttons and switches  
        .btnC_0(btnC),
        .btnD_0(btnD),
        .btnL_0(btnL),
        .btnR_0(btnR),
        .btnU_0(btnU),
        .sw_0(sw),
        // reset and clock 
        .sysreset_n(sysreset_n),
        .sysclk(sysclk));

// Tristate buffers for the pmodOLEDrgb pins
// generated by PMOD bridge component.  Many
// of these signals are not tri-state.
IOBUF pmodoledrgb_out_pin1_iobuf
(
    .I(pmodoledrgb_out_pin1_o),
    .IO(pmodoledrgb_out_pin1_io),
    .O(pmodoledrgb_out_pin1_i),
    .T(pmodoledrgb_out_pin1_t)
);

IOBUF pmodoledrgb_out_pin2_iobuf
(
    .I(pmodoledrgb_out_pin2_o),
    .IO(pmodoledrgb_out_pin2_io),
    .O(pmodoledrgb_out_pin2_i),
    .T(pmodoledrgb_out_pin2_t)
);

IOBUF pmodoledrgb_out_pin3_iobuf
(
    .I(pmodoledrgb_out_pin3_o),
    .IO(pmodoledrgb_out_pin3_io),
    .O(pmodoledrgb_out_pin3_i),
    .T(pmodoledrgb_out_pin3_t)
);

IOBUF pmodoledrgb_out_pin4_iobuf
(
    .I(pmodoledrgb_out_pin4_o),
    .IO(pmodoledrgb_out_pin4_io),
    .O(pmodoledrgb_out_pin4_i),
    .T(pmodoledrgb_out_pin4_t)
);

IOBUF pmodoledrgb_out_pin7_iobuf
(
    .I(pmodoledrgb_out_pin7_o),
    .IO(pmodoledrgb_out_pin7_io),
    .O(pmodoledrgb_out_pin7_i),
    .T(pmodoledrgb_out_pin7_t)
);

IOBUF pmodoledrgb_out_pin8_iobuf
(
    .I(pmodoledrgb_out_pin8_o),
    .IO(pmodoledrgb_out_pin8_io),
    .O(pmodoledrgb_out_pin8_i),
    .T(pmodoledrgb_out_pin8_t)
);

IOBUF pmodoledrgb_out_pin9_iobuf
(
    .I(pmodoledrgb_out_pin9_o),
    .IO(pmodoledrgb_out_pin9_io),
    .O(pmodoledrgb_out_pin9_i),
    .T(pmodoledrgb_out_pin9_t)
);

IOBUF pmodoledrgb_out_pin10_iobuf
(
    .I(pmodoledrgb_out_pin10_o),
    .IO(pmodoledrgb_out_pin10_io),
    .O(pmodoledrgb_out_pin10_i),
    .T(pmodoledrgb_out_pin10_t)
);

// Tristate buffers for the pmodENC pins
// generated by PMOD bridge component.  Many
// of these signals are not tri-state.
IOBUF Pmod_out_0_pin1_iobuf
     (.I(Pmod_out_0_pin1_o),
      .IO(Pmod_out_0_pin1_io),
      .O(Pmod_out_0_pin1_i),
      .T(Pmod_out_0_pin1_t));
	  
IOBUF Pmod_out_0_pin2_iobuf
     (.I(Pmod_out_0_pin2_o),
      .IO(Pmod_out_0_pin2_io),
      .O(Pmod_out_0_pin2_i),
      .T(Pmod_out_0_pin2_t));
	  
IOBUF Pmod_out_0_pin3_iobuf
     (.I(Pmod_out_0_pin3_o),
      .IO(Pmod_out_0_pin3_io),
      .O(Pmod_out_0_pin3_i),
      .T(Pmod_out_0_pin3_t));
	  
IOBUF Pmod_out_0_pin4_iobuf
     (.I(Pmod_out_0_pin4_o),
      .IO(Pmod_out_0_pin4_io),
      .O(Pmod_out_0_pin4_i),
      .T(Pmod_out_0_pin4_t));
	  
IOBUF Pmod_out_0_pin7_iobuf
     (.I(Pmod_out_0_pin7_o),
      .IO(Pmod_out_0_pin7_io),
      .O(Pmod_out_0_pin7_i),
      .T(Pmod_out_0_pin7_t));
	  
IOBUF Pmod_out_0_pin8_iobuf
     (.I(Pmod_out_0_pin8_o),
      .IO(Pmod_out_0_pin8_io),
      .O(Pmod_out_0_pin8_i),
      .T(Pmod_out_0_pin8_t));
	  
IOBUF Pmod_out_0_pin9_iobuf
     (.I(Pmod_out_0_pin9_o),
      .IO(Pmod_out_0_pin9_io),
      .O(Pmod_out_0_pin9_i),
      .T(Pmod_out_0_pin9_t));
	  
IOBUF Pmod_out_0_pin10_iobuf
     (.I(Pmod_out_0_pin10_o),
          .IO(Pmod_out_0_pin10_io),
          .O(Pmod_out_0_pin10_i),
          .T(Pmod_out_0_pin10_t));

endmodule
