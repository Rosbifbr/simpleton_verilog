
module simpleton_pitanga(clk,
                         rst,
                         oEndMem_7s,
                         oEndMem_MS,
                         oMem128_7s,
                         oEA);
    input       clk;        // relógio do sistema (clock)
    input       rst;        // reset
    
    //output      blk;        // saída de relógio (para piscar led)
    
    // Sinais de Dados
    //output [7:0] OutAC;   // sair o valor do acumulador para debugar
    //output [7:0] OutPC;   // sair o valor do PC para debugar
    //output [7:0] OutREM;   // sair o valor do REM para debugar
    //output [7:0] resultado;   // resultado da memoria, para debugar
    
    //output	oselPC;
    //output	oenPC;
    //output	oselMEM;
    //output	oenREM;
    //output	owrite;
    //output	oopULA;
    //output	oenAC;
    
    output [2:0] oEA;
    
    //output [7:0] oDregPC; // entrada do PC
    //output [7:0] oQregPC; // saida do PC
    //output [7:0] oPCm1; // saida do incrementador
    //output [7:0] oQrem; // saida do REM
    output [6:0] oEndMem_7s; // endereço da memoria
    output oEndMem_MS;
    //output [7:0] oOutMem; // saida da memoria
    //output [7:0] oDregAC; // entrada do AC
    //output [7:0] oQregAC; // saida do AC
    output [6:0] oMem128_7s; // O que foi escrito na memória
    wire [7:0] wMem128;
    
    
    wire SelPC, EnPC, EnREM, SelMem, Write, OpULA, EnAC, z;
    assign z = 1'b0;
    wire [7:0] DregPC; // entrada do PC
    wire [7:0] QregPC; // saida do PC
    wire [7:0] PCm1; // saida do incrementador
    wire [7:0] Qrem; // saida do REM
    wire [7:0] EndMem; // endereço da memoria
    wire [7:0] OutMem; // saida da memoria
    wire [7:0] DregAC; // entrada do AC
    wire [7:0] QregAC; // saida do AC
    
    //assign OutAC  = QregAC;
    //assign OutPC  = QregPC;
    //assign OutREM = Qrem;
    
    display7seg disp_EndMem(.in(EndMem[3:0]), .out(oEndMem_7s));
    display7seg disp_Mem128(.in(wMem128[3:0]), .out(oMem128_7s));
    assign oEndMem_MS = EndMem[7];
    
    mais_um_pit incrementapc(.a(QregPC), .s(PCm1));
    mux21_8b_pit muxpc(.sel(SelPC), .e1(PCm1), .e0(OutMem), .saida(DregPC));
    mux21_8b_pit muxmemoria(.sel(SelMem), .e1(QregPC), .e0(Qrem), .saida(EndMem));
    reg8_pit REM(.clk(clk), .rst(rst), .set(z), .cen(EnREM), .d(OutMem), .q(Qrem));
    reg8_pit PC(.clk(clk), .rst(rst), .set(z), .cen(EnPC), .d(DregPC), .q(QregPC));
    reg8_pit AC(.clk(clk), .rst(rst), .set(z), .cen(EnAC), .d(DregAC), .q(QregAC));
    memoria_pit memoria_neandreis(.write(Write), .clk(clk), .rst(rst), .address(EndMem),
    .din(QregAC), .dout(OutMem), .oMem128(wMem128));
    ula_pit ula_neandreis(.a(OutMem), .b(QregAC), .op(OpULA), .s(DregAC));
    controle_simpleton_pit cs(.clk(clk), .rst(rst), .inst_in(OutMem[7:4]),
    .selPC(SelPC), .enPC(EnPC), .selMEM(SelMem), .enREM(EnREM),
    .write(Write), .opULA(OpULA), .enAC(EnAC), .oEA(oEA));
    
    
    
    //assign	oselPC  = SelPC;
    //assign	oenPC   = EnPC;
    //assign	oselMEM = SelMem;
    //assign	oenREM  = EnREM;
    //assign	owrite  = Write;
    //assign	oopULA  = OpULA;
    //assign	oenAC   = EnAC;
    
    
    //assign oDregPC = DregPC; // entrada do PC
    //assign oQregPC = QregPC; // saida do PC
    //assign oPCm1   = PCm1; // saida do incrementador
    //assign oQrem   = Qrem; // saida do REM
    //assign oEndMem = EndMem; // endereço da memoria
    //assign oOutMem = OutMem; // saida da memoria
    //assign oDregAC = DregAC; // entrada do AC
    //assign oQregAC = QregAC; // saida do AC
    
    
    
endmodule





//mais_um incrementapc(.a(), .s());
module mais_um_pit(a, s);
    
    input [7:0]	a;
    output[7:0]	s;
    
    assign s = a+1;
    
    
endmodule



//mux21_8b muxpc(.sel(), .e1(), .e0(), .saida(fio_pctem_1));
module mux21_8b_pit(sel, e1, e0, saida);
    
    input	sel;
    input [7:0]	e1;
    input [7:0]	e0;
    output[7:0]	saida;
    
    assign saida = (sel) ? e1 :  e0;
    
    
endmodule



//reg8 REM(.clk(), .rst(), .set(), .cen(), .d(), .q());
module reg8_pit(clk, rst, set, cen, d, q);
    input clk, rst, set, cen;
    input [7:0] d;
    output reg [7:0] q;
    
    always@(posedge clk, posedge rst) begin
        if (rst)
            q <= 8'b00000000;
        else if (set)
            q <= 8'b11111111;
        else if (cen)
            q <= d;
        else
            q <= q;
    end
endmodule



module memoria_pit(
    input write,
    input clk,
    input rst,
    input [7:0] address,      // 8-bit register input
    input [7:0] din,
    output  [7:0] dout,
    output  [7:0] oMem128
    );   // 8-bit register output
    
    wire [7:0] saida_rom;
    wire [7:0] saida_ram;
    wire enable;
    wire zero, nrst;
    not (nrst, rst);
    and (zero, nrst, rst);
    and(enable, address[7], write);
    rom_prog_pit rp(.address(address), .content(saida_rom));
    reg8_pit r(.d(din), .q(saida_ram), .clk(clk), .rst(rst), .set(), .cen(enable));
    mux21_8b_pit m8b(.e0(saida_rom), .e1(saida_ram), .sel(address[7]), .saida(dout));
    
    assign oMem128 = saida_ram;
    
endmodule


module rom_prog_pit(
    
    input [7:0] address,      // 8-bit register input
    output  [7:0] content);   // 8-bit register output
    
    wire [7:0] naddress;
    wire [7:0] minterm;
    not(naddress[0], address[0]);
    not(naddress[1], address[1]);
    not(naddress[2], address[2]);
    not(naddress[3], address[3]);
    not(naddress[4], address[4]);
    not(naddress[5], address[5]);
    not(naddress[6], address[6]);
    not(naddress[7], address[7]);
    
    and(minterm[0], naddress[2], naddress[1], naddress[0]);
    and(minterm[1], naddress[2], naddress[1],  address[0]);
    and(minterm[2], naddress[2],  address[1], naddress[0]);
    and(minterm[3], naddress[2],  address[1],  address[0]);
    and(minterm[4],  address[2], naddress[1], naddress[0]);
    and(minterm[5],  address[2], naddress[1],  address[0]);
    and(minterm[6],  address[2],  address[1], naddress[0]);
    and(minterm[7],  address[2],  address[1],  address[0]);
    
    or(content[0], minterm[1], minterm[3], minterm[7]);
    or(content[1], minterm[1], minterm[3]);
    or(content[2], minterm[1], minterm[3], minterm[7]);
    and(content[3], address[0], naddress[0]); //none
    or(content[4], minterm[2], minterm[4], minterm[6]);
    or(content[5], minterm[0], minterm[2], minterm[6]);
    buf(content[6], minterm[6]);
    or(content[7], minterm[5], minterm[6]);
    
endmodule



//ula ula_neandreis(.a(), .b(), .op(), .s());

module ula_pit(a, b, op, s);
    
    input [7:0]	a;
    input [7:0]	b;
    input 	op;
    output[7:0]	s;
    
    wire [7:0]	soma;
    assign soma = a+b;
    
    assign s = (op) ? soma :  a;
    
endmodule


module controle_simpleton_pit(clk, rst, inst_in, selPC, enPC, selMEM, enREM, write, opULA, enAC, oEA);
    input clk;
    input rst;
    input [3:0]	inst_in;
    output	selPC;
    output	enPC;
    output	selMEM;
    output	enREM;
    output	write;
    output	opULA;
    output	enAC;
    output  [2:0] oEA;
    
    wire enable;
    wire [4:0] entradas_cc;
    wire [2:0] PE;
    reg [2:0] EA;
    
    //instancia do tradutor: não mexe que estraga: inicio
    nor (enable, EA[2], EA[1], EA[0]);
    wire [1:0] inst_temp;
    //instancia do tradutor: não mexe que estraga: meio
    trad_inst_pit tradutor(.clk(clk), .enable(enable), .inst_in(inst_in), .inst_out(inst_temp));
    //instancia do tradutor: não mexe que estraga: fim
    
    
    //vetor concatenado para dar tabelas iguais aos slides
    assign entradas_cc[4:3] = inst_temp;
    assign entradas_cc[2:0] = EA;
    assign oEA              = EA;
    
    // Descrição do CCPE, trocar por uma chamada de CCPE com equações
    //assign PE = 
    ////HLT 00
    //(entradas_cc == 5'b00000)  ?   3'b101:
    //(entradas_cc == 5'b00001)  ?   3'b101:
    //(entradas_cc == 5'b00010)  ?   3'b101:
    //(entradas_cc == 5'b00011)  ?   3'b101:
    //(entradas_cc == 5'b00100)  ?   3'b101:
    //(entradas_cc == 5'b00101)  ?   3'b101:
    ////STA 01
    //(entradas_cc == 5'b01000)  ?   3'b001:
    //(entradas_cc == 5'b01001)  ?   3'b100:
    //(entradas_cc == 5'b01010)  ?   3'b000:
    //(entradas_cc == 5'b01011)  ?   3'b000:
    //(entradas_cc == 5'b01100)  ?   3'b000:
    //(entradas_cc == 5'b01101)  ?   3'b000:
    ////LDA 10
    //(entradas_cc == 5'b10000)  ?   3'b001:
    //(entradas_cc == 5'b10001)  ?   3'b010:
    //(entradas_cc == 5'b10010)  ?   3'b000:
    //(entradas_cc == 5'b10011)  ?   3'b000:
    //(entradas_cc == 5'b10100)  ?   3'b000:
    //(entradas_cc == 5'b10101)  ?   3'b000:
    ////ADD 11
    //(entradas_cc == 5'b11000)  ?   3'b001:
    //(entradas_cc == 5'b11001)  ?   3'b011:
    //(entradas_cc == 5'b11010)  ?   3'b000:
    //(entradas_cc == 5'b11011)  ?   3'b000:
    //(entradas_cc == 5'b11100)  ?   3'b000:
    //(entradas_cc == 5'b11101)  ?   3'b000:
    //3'b101; //caso default para tudo

    //Circuit implementation
    wire ecc43nor;
    nor (ecc43nor, entradas_cc[4], entradas_cc[3]); //minterm 1
    wire ecc43and, norrest;
    nor (norrest, entradas_cc[4], entradas_cc[2], entradas_cc[1], entradas_cc[0]); //all others negated
    and (ecc43and, entradas_cc[3], norrest); //maxterm 2
    //last digit
    or(PE[2], ecc43nor, ecc43and); //Ultimo digito 1 when nor (ecc4, ecc3) OR and (necc4, ecc3)

    wire eccrestnor;
    nor (eccrestnor, entradas_cc[2], entradas_cc[1]); //mintermo1
    //PE1 = true sse (ecc4 & ecc0) & !(ecc2 | ecc1) ;; ecc3 = dont care
    and (PE[1], entradas_cc[0], entradas_cc[4], eccrestnor); //second digit

    //PE0
    //ecc43nor -> maxterm
    //eccrestnor & ecc4 & ecc3 -> maxterm
    //(eccrestnor & !ecc0) | ecc4 | ecc3 -> maxterm
    wire lastm1, necc0, _lastm2, lastm2;
    and (lastm1, eccrestnor, entradas_cc[4], entradas_cc[3]);

    not (necc0, entradas_cc[0]);
    and(_lastm2, eccrestnor, necc0);
    or (lastm2, _lastm2, entradas_cc[4], entradas_cc[3]);
    or (PE[0], ecc43nor, lastm1, lastm2);

    
    
    //descrição do CCSaida, trocar por uma chamada de CCSaida com equações
    wire [6:0] saidas;
    
    assign saidas = 
    //HLT 00
    (EA == 3'b000)  ?   7'b1110000: //Estado inicial igual para todas instruções
    (EA == 3'b001)  ?   7'b1111000: //Le imediato, mesma coisa para LDA, ADD e STA
    (EA == 3'b010)  ?   7'b1000001: // acc-<mem PD = 0, definimos
    (EA == 3'b011)  ?   7'b1000011: // acc-<mem+acc soma = 1, definimos
    (EA == 3'b100)  ?   7'b1000100: // mem<-acc
    (EA == 3'b101)  ?   7'b0000000: // HLT
    
    7'b0000000; //default recebe 0
    
    //atribui as saidas, talvez parte do ccsaida
    buf(selPC, saidas[6]);
    buf(enPC, saidas[5]);
    buf(selMEM, saidas[4]);
    buf(enREM, saidas[3]);
    buf(write, saidas[2]);
    buf(opULA, saidas[1]);
    buf(enAC, saidas[0]);
    
    
    //faz o reg 2 direto, trocar por uma chamada de reg2 chamando dois FFs
    //function implementation
    //always@(posedge clk) begin
    //    if (rst)
    //        EA <= 2'b00;  // reseta
    //    else
    //        EA <= PE;
    //end
    
    //circuit implementation (bad but should work)
    //invert clock and reset for edge detection
    wire valid, nrst, _posedge;
    wire _sd, sd[6:0]; //gambiarra to generate small delay

    //pass clk through sd and some gates to gnerate delay (wasteful, i know)
    and (sd[0], clk, 1);
    and (sd[1], sd[0], 1);
    and (sd[2], sd[1], 1);
    and (sd[3], sd[2], 1);
    and (sd[4], sd[3], 1);
    and (sd[5], sd[4], 1);
    not (_sd, sd[5]); //_sd = !sd[5]

    and (_posedge, _sd, clk); //detect rising edge
    not (nrst, rst);

    and (valid, _posedge, nrst); //posedge clock on and rst off
    and (EA[1], valid, PE[1]);
    and (EA[0], valid, PE[0]);
endmodule



module trad_inst_pit(clk, enable, inst_in, inst_out);
    input clk;
    input enable;
    input [3:0]	inst_in;
    output[1:0]	inst_out;
    
    wire [1:0] inst_temp_variavel;
    wire [1:0] inst_temp_registrado;
    reg [1:0] inst_reg;
    // Descrição da arquitetura
    assign inst_temp_variavel = 
    (inst_in == 4'b1111)  ?   2'b00: //HLT
    (inst_in == 4'b0001)  ?   2'b01: //STA
    (inst_in == 4'b0010)  ?   2'b10: //LDA
    (inst_in == 4'b0011)  ?   2'b11: //ADD
    2'b00; //Caso default, mapeado para HLT
    assign inst_temp_registrado = inst_reg;
    
    assign inst_out = 
    (enable) ? inst_temp_variavel : inst_temp_registrado;
    
    
    always@(posedge clk) begin
        if (enable)
            inst_reg <= inst_temp_variavel;   //
            end
        
        
        
        endmodule
        
        
        module display7seg(in, out);
            input [3:0]	in;
            output[6:0]	out;
            // Descrição da arquitetura
            assign out = 
            (in == 4'b0000)  ?   7'b1111110:
            (in == 4'b0001)  ?   7'b0110000:
            (in == 4'b0010)  ?   7'b1101101:
            (in == 4'b0011)  ?   7'b1111001:
            
            (in == 4'b0100)  ?   7'b0110011:
            (in == 4'b0101)  ?   7'b1011011:
            (in == 4'b0110)  ?   7'b1011111:
            (in == 4'b0111)  ?   7'b1110000:
            
            (in == 4'b1000)  ?   7'b1111111:
            (in == 4'b1001)  ?   7'b1111011:
            (in == 4'b1010)  ?   7'b1110111:
            (in == 4'b1011)  ?   7'b0011111:
            
            (in == 4'b1100)  ?   7'b1001110:
            (in == 4'b1101)  ?   7'b0111101:
            (in == 4'b1110)  ?   7'b1001111:
            7'b1000111;
            
            
        endmodule
        
        
        
