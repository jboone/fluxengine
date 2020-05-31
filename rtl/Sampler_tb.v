`default_nettype none
`timescale 1ns / 1ns

module Sampler_tb;
	
	reg clk_system = 0;
	always #7.8125 clk_system = !clk_system;
	// always #8.3333 clk_system = !clk_system;

	reg clk_sample = 0;
	always #41.6667 clk_sample = !clk_sample;

	reg reset = 0;

	integer ticks = 0;
	integer ticks_next_pulse = 0;

	integer pulse_duration = 5;

	reg pulse = 0;

	always @(posedge clk_system) begin
		ticks <= ticks + 1;

		if (ticks == ticks_next_pulse) begin
			pulse <= 1;
			pulse_duration <= pulse_duration + 1;
			ticks_next_pulse <= ticks + pulse_duration;
		end else begin
			pulse <= 0;
		end
	end

	// Test pulse history, used for pulse-stretching
	reg [7:0] pulse_q;

	// OR the six most recent pulse values to stretch the pulse to six clocks.
	wire pulse_stretched = |pulse_q[5:0];

	always @(posedge clk_system) begin
		pulse_q <= { pulse_q[6:0], pulse };
	end

	wire rdata = pulse_stretched;	

	reg index = 0;

	wire       before_req;
	wire [7:0] before_opcode;

	Sampler_before before(
		.reset(reset),

		.clock(clk_system),
		.sampleclock(clk_sample),

		.index(index),
		.rdata(rdata),

		.req(before_req),
		.opcode(before_opcode)

		// .debug_state()
	);

	wire       after_req;
	wire [7:0] after_opcode;

	Sampler_after after(
		.reset(reset),

		.clock(clk_system),
		.sampleclock(clk_sample),

		.index(index),
		.rdata(rdata),

		.req(after_req),
		.opcode(after_opcode)

		// .debug_state()
	);

	integer f_ticks;
	integer f_before;
	integer f_after;

	initial begin
		f_ticks  = $fopen("ticks.u32", "wb");
		f_before = $fopen("before_opcodes.u8", "wb");
		f_after  = $fopen("after_opcodes.u8", "wb");

		repeat(1) @(posedge clk_system);
		reset <= 1;
		repeat(10) @(posedge clk_system);
		reset <= 0;

		repeat(1000000) @(posedge clk_system);

		$fclose(f_ticks);
		$fclose(f_before);
		$fclose(f_after);

		$finish;
	end

	always @(posedge clk_system) begin
		if (pulse) begin
			$fwrite(f_ticks, "%c%c%c%c", ticks[7:0], ticks[15:8], ticks[23:16], ticks[31:24]);
		end

		if (before_req) begin
			$fwrite(f_before, "%c", before_opcode);
		end

		if (after_req) begin
			$fwrite(f_after, "%c", after_opcode);
		end
	end

	initial begin
		$dumpfile("Sampler_tb.fst");
		$dumpvars(0, Sampler_tb);
	end

endmodule
