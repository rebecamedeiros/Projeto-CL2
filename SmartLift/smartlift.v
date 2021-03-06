module smartlift(/*SW, LED_G, LED_R, HEX0, HEX1, KEY0, CLOCK_50, LCD_DATA, 
				 LCD_EN, LCD_RS, LCD_RW, LCD_ON, LCD_BLON*/
				 output	[7:0]	LCD_DATA, //entrada do lcd
				 output	LCD_RW, LCD_EN, LCD_RS, LCD_ON, LCD_BLON, //sa�da do lcd
				 input [8:0]SW, 		//andar selecionado
				 input KEY0,         //solicitar o andar
				 input CLOCK_50,		
				 output reg LED_G,	//porta aberta
	             output reg LED_R,	//porta fechada
	             output reg[6:0]HEX0,	//print andar selecionado
	             output reg[6:0]HEX1
	             );
	wire DLY_RST;
	reg rs = 0;
	reg [31:0] aux;
	reg [31:0] CLOCK;
	reg [31:0] aux2;
	reg [31:0] CLOCK2;
	reg [60:0] aux3;
	reg [60:0] CLOCK3;
	
	reg i = 1;
	reg j = 1;
	
	
	integer count = 0;
	
	// turn LCD ON
	assign    LCD_ON        =    1'b1;
	assign    LCD_BLON    =    1'b1;
	
	
	//seg - (a, b, c, d, e, f, g)
	//seg - 1 desligado e 0 ligado
	
	//reg verifica_reset = 0;
	// integer movimento; // 0 - parado, 1 - subindo, 2 - descendo 
	integer s; //andar solicitado
	integer aux_s; //andar atual
	reg [1:0] estado_atual;
	parameter parado = 0, subindo = 1, descendo = 2;// inativo = 3;
	// parado subindo descendo 		
	
	always @(posedge CLOCK_50)begin
		if(aux == 0)begin
			aux  <= 24999999;
			CLOCK <= ~CLOCK;
		end else begin
			aux <= aux - 1;
		end
	end
	
	always @(posedge CLOCK_50)begin
		if(aux2 == 0)begin
			aux2  <= 49999999;
			CLOCK2 <= ~CLOCK2;
		end else begin
			aux2 <= aux2 - 1;
		end
	end	
	
	
	always @( negedge KEY0 ) begin 
		case (SW) 	
						9'b000000001: begin
							HEX0 = 7'b1000000; //se o andar selecionado for 0
							s = 0;
						end	
						
						9'b000000010: begin
							HEX0 = 7'b1111001; //se o andar selecionado for 1
							s = 1;
						end
						
						9'b000000100: begin
							HEX0 = 7'b0100100; //se o andar selecionado for 2
							s = 2;
						end
						
						9'b000001000: begin
							HEX0 = 7'b0110000; //se o andar selecionado for 3
							s = 3;
						end	
						
						9'b000010000: begin
							HEX0 = 7'b0011001; //se o andar selecionado for 4
							s = 4;
						end
						
						9'b000100000: begin
							HEX0 = 7'b0010010; //se o andar selecionado for 5
							s = 5;
						end
						
						9'b001000000: begin
							HEX0 = 7'b0000010; //se o andar selecionado for 6
							s = 6;
						end
						
						9'b010000000: begin 
							HEX0 = 7'b1111000; //se o andar selecionado for 7
							s = 7;
						end
						
						9'b100000000: begin 
							HEX0 = 7'b0000000; //se o andar selecionado for 8                                                                                                                                                                                                              1; //se o andar selecionado for 8
							s = 8;
						end
						
						default: begin 
							HEX0 = 7'b1110111;  //default: _ , nenhuma andar solicitado
						end 
			endcase
	end
	

	always begin //parte combinacional 	
		case (aux_s)
			0: begin
				HEX1 = 7'b1000000; //andar atual = 0
			end
			
			1: begin 
				HEX1 = 7'b1111001; //andar atual = 1
			end
			
			2: begin 
				HEX1 = 7'b0100100; //andar atual = 2
			end
			
			3: begin 
				HEX1 = 7'b0110000; //andar atual = 3
			end
			
			4: begin 
				HEX1 = 7'b0011001; //andar atual = 4
			end
			
			5: begin 
				HEX1 = 7'b0010010; //andar atual = 5
			end
			
			6: begin 
				HEX1 = 7'b0000010; //andar atual = 6
			end
			
			7: begin 
				HEX1 = 7'b1111000; //andar atual = 7
			end
			
			8: begin 
				HEX1 = 7'b00000000; //andar atual = 8
			end
		endcase
	end
	
	always @( CLOCK ) begin
		if ( estado_atual == parado ) begin 
			LED_G = 1;
			LED_R = 0;
		end 
		else begin 
			LED_G = 0;
			LED_R = 1;
		end
		
	end
	
	
	always @( posedge CLOCK2 ) begin //parte sequencial 
		rs = 0;
		case (estado_atual)
			
			parado: begin
			
				if (s > aux_s ) begin 
					estado_atual = subindo;
					rs = 1;		
				end else if (s < aux_s) begin
					estado_atual = descendo;
					rs = 1;
				end
			end
			
			subindo: begin
				aux_s = aux_s + 1;
				if (s == aux_s) begin
					estado_atual = parado;
					rs = 1;
				end
			end
			descendo: begin 
				aux_s = aux_s - 1;
				if (s == aux_s ) begin
					estado_atual = parado;
					rs = 1;
				end
			end
			
			/*inativo: begin 
				aux_s = aux_s - 1;
				if (aux_s == 0) begin
					estado_atual = parado;
				end
			end*/
			endcase
			
	end		
	
	
	Reset_Delay r0(    .iCLK(CLOCK_50),.oRESET(DLY_RST));

	
	LCD_TEST u1(
		// Host Side
		.iCLK(CLOCK_50),
		.iRST_N(DLY_RST),
		// LCD Side
		.LCD_DATA(LCD_DATA),
		.LCD_RW(LCD_RW),
		.LCD_EN(LCD_EN),
		.LCD_RS(LCD_RS),
		.estado_atual(estado_atual),
		.Reset(rs)
	);
		
	
endmodule
		
