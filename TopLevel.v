// Amanda Lee + Rachel Mathew
// Computer Architecture Final Project


//FPGA Top Module
module topModule(led, speaker, clk, sw, btn);
	output [7:0] led;
	output speaker;
	input clk;
	input[7:0] sw;
	input[3:0] btn;
	assign led = 0;
	wire btnCond; 
	wire btnPos; 
	wire btnNeg;
	
	inputconditioner_fault btnCondition(clk, btn[0], btnCond, btnPos, btnNeg, 0);
	octaveChanger playMusic(clk, speaker, btnPos ,sw[0]);
	distort distorter (clk, speaker, sw[1]);
	//music song (clk, speaker);  
endmodule


//Changes the octave of a single note with the press of a button. 
module octaveChanger(clk, speaker, btn, sw);
	input clk;
	output speaker;
	input btn;
	input sw;
		
	reg [2:0] btnCounts; 
	reg [14:0] counter;
	reg [14:0] counter1;
	reg [14:0] counter2;
	reg [14:0] counter3;
	always @(posedge clk) if(counter==0) counter <= 25000000/220/2-1; else counter <= counter-1;
	always @(posedge clk) if(counter1==0) counter1 <=25000000/440/2-1; else counter1 <= counter1-1;
	always @(posedge clk) if(counter2==0) counter2 <= 25000000/880/2-1; else counter2 <= counter2-1;
	always @(posedge clk) if(counter3==0) counter3 <=25000000/1660/2 -1; else counter3 <= counter3-1;
	
	always @(posedge clk) begin
		if (btn) begin 
			btnCounts = btnCounts + 1;
		end
		if (btnCounts == 4) begin
			btnCounts = 0;
		end
	end

	reg speaker;
	//reg pos = 1; 
	always @(posedge clk) begin
		if(btnCounts==0 && counter==0 && sw) begin
			speaker <= ~speaker; 
		end
		else if(btnCounts==1 && counter1==0 && sw) begin
			speaker <= ~speaker;
		end
		else if(btnCounts==2 && counter2==0 && sw) begin
			speaker <= ~speaker; 
		end
		else if(btnCounts==3 && counter3==0 && sw) begin
			speaker <= ~speaker; 
		end
	end
endmodule

// input conditioner
module inputconditioner_fault(clk, noisysignal, conditioned, positiveedge, 
negativeedge, faultinjector_pin);
  output reg conditioned, positiveedge, negativeedge;
  input clk, noisysignal, faultinjector_pin;
  parameter counterwidth = 3;
  parameter waittime = 3;
  reg synchronizer0;
  reg[counterwidth-1:0] counter =0;
  reg synchronizer1 = 1;
  
  initial begin
    conditioned = noisysignal;
    positiveedge = 0;
    negativeedge = 0;
  end

  always @(posedge clk ) begin
    if(conditioned == synchronizer1) begin
      counter <= 0;
      positiveedge=0;
      negativeedge=0;
    end
    else begin
      if( counter == waittime) begin
        counter <= 0;
        conditioned <= synchronizer1;
        if(synchronizer1 == 1)
          positiveedge = 1;
        else
          negativeedge = 1;        
      end
      else 
        counter <= counter+1;
      end 
      synchronizer1 = synchronizer0;
      //if faultinjector pin is high show noisysignal
      synchronizer0 = (faultinjector_pin == 0)? noisysignal : 1;
  end
endmodule

//distorts the standard note by switching between two tones quickly
module distort(clk, speaker, sw);
	input clk;
	output speaker;
	parameter clkdivider = 25000000/440/2;

	reg [21:0] tone;
	always @(posedge clk) tone <= tone+1;

	reg [14:0] counter;
	always @(posedge clk) if(counter==0) counter <= (tone[21] ? clkdivider-1 : clkdivider/2-1); else counter <= counter-1;

	reg speaker;
	always @(posedge clk) if(counter==0 && sw) speaker <= ~speaker;
endmodule


//used for testing
module music(clk, speaker, dutyCounter);
	input clk;
	output speaker;
	//parameter clkdivider = 25000000/440/4;
	parameter clkdivider = 8/4;
	parameter clkdivider2 = 3*clkdivider;

	reg [14:0] counter;
	output reg dutyCounter;
	always @(posedge clk) begin 
		if(counter==0) begin 
			if (dutyCounter==1) counter <= clkdivider-1; else counter <= clkdivider2-1;
			dutyCounter <= dutyCounter ^ 1'b1;
		end	
		else counter <= counter-1;
	end

	reg speaker;
	always @(posedge clk) if(counter==0) speaker <= speaker^1'b1;

	initial begin
		dutyCounter = 0;
		speaker = 1;
		counter = 0;
	end
endmodule

module musicTest;
reg clk;
wire speaker;
wire dutyCounter;
reg[31:0] count;

music musicTester(clk, speaker, dutyCounter);

initial begin
	clk = 0;
	count = 0;
	while (count < 32'd3000) begin
		clk= !clk; #10
		count = count + 1;
	end
	$display();
end

endmodule
