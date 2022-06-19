`timescale 1ns / 1ps
module num_module(
        input [3:0]number,
        input param,
        input CLK,
        output reg[6:0]digit
        );
    always@(posedge CLK) 
        if (param)   
          case(number) 
            4'd0 : digit <= 7'b0111111;
            4'd1 : digit <= 7'b0000110;
            4'd2 : digit <= 7'b1011011;
            4'd3 : digit <= 7'b1001111;
            4'd4 : digit <= 7'b1100110;
            4'd5 : digit <= 7'b1101101;
            4'd6 : digit <= 7'b1111101;
            4'd7 : digit <= 7'b0000111;
            4'd8 : digit <= 7'b1111111;
            4'd9 : digit <= 7'b1101111;
          endcase
        else 
            digit <= 7'b0000000;
endmodule

module main_clock(    
    input CLK,
    input [3:0]state,
    output wire compare,
    output [1:0]pos,
    output [3:0]number1,
    output [3:0]number2,
    output [3:0]number3,
    output [3:0]number4,
    output mid_d,
    output need_to_fl
    );
    reg [3:0]min_2;
    reg [3:0]min_1;
    reg [3:0]hour_2;
    reg [3:0]hour_1;
    reg [5:0]dot = 0;
    reg [23:0]main_cnt = 0;
    reg [0:0]button_press = 0;
    reg [1:0]position = 0;
    reg [0:0]need_to_flash;
    reg [0:0] mid_dot; 
    
    //wire compare;
    assign compare = (main_cnt >= 6000000);
                  
    always_ff@(posedge CLK)
      begin
            case (state)
            4'b0111 : begin
                       main_cnt<=24'b0;
                       dot<= 5'b0;
                       min_2<=4'b0;
                       min_1<=4'b0;
                       hour_2<=4'b0;
                       hour_1<=4'b0;
                       button_press<=1'b0;
                       position<=2'b0;
                     end
            4'b1011 : begin
                     need_to_flash <= 1'b1; 
                     if (main_cnt[20:0]==0)                     
                        button_press <= button_press + 1;   
                     if (button_press == 0)
                       begin 
                           need_to_flash <= 1'b0;
                       end
                     end
            4'b1101 : begin
                       if(button_press == 1)
                          if (main_cnt[20:0]==0)     
                              position <= position + 1;        
                     end
            4'b1110:  if(button_press == 1)
                         if (main_cnt[20:0]==0)
                          case (position)
                             0: if (hour_1 == 2)
                                  hour_1 <=  4'b0;
                                else
                                  hour_1 <= hour_1 + 1;        
                             1:begin
                                if (hour_2 == 9)
                                      hour_2 <=4'b0;
                                else if(hour_1 == 2 && hour_2 == 3)
                                      hour_2 <=4'b0;
                                else 
                                      hour_2 <= hour_2 + 1;    
                                end        
                             2:if (min_1 == 5)
                                   min_1 <=  4'b0;
                               else
                                   min_1 <= min_1 + 1;
                             3: if (min_2 == 9) 
                                    min_2 <=  4'b0;
                                else
                                    min_2 <= min_2 + 1;
                          endcase   
                               
            4'b1111: begin 
                if (button_press == 0)
                  begin
                    if (main_cnt[23:0] < 6000000)
                         mid_dot<=1; 
                     if (main_cnt[23:0] >= 6000000)
                         mid_dot<=0;
                     if (main_cnt[23:0] == 12000000)
                         begin
                         main_cnt <= 0;
                         if (dot == 59)
                            begin
                            dot<=0;
                            if (min_2 == 9)
                               begin
                               min_2<=0;
                               if (min_1 == 5)
                                  begin
                                  min_1<=0;
                                  if (hour_2 == 3 && hour_1 == 2)
                                    begin
                                    hour_2 <= 0;
                                    hour_1 <= 0;
                                    end
                                  else if (hour_2 == 9)
                                    begin
                                    hour_2 <=0;
                                    hour_1 <= hour_1 + 1;
                                    end                      
                                  else
                                      hour_2 <= hour_2 + 1;
                                  end
                              else
                                min_1 <= min_1 + 1;  
                              end
                           else
                              min_2 <= min_2 + 1; 
                           end
                         else
                            dot <= dot + 1;  
                         end  
                   end
                 end               
                 endcase
                 main_cnt <= main_cnt + 1;
     end
     assign number1 = hour_1;
     assign number2 = hour_2;
     assign number3 = min_1;
     assign number4 = min_2;
     assign need_to_fl = need_to_flash;
     assign pos = position;
     assign mid_d = mid_dot;
//    num_module nm0(.number(hour_1),.param(compare && (position == 2'b00) || ((position == 2'b00)^(need_to_flash == 1'b1)) ||(need_to_flash == 1'b0)),.CLK(CLK),.digit(led1));
//    num_module nm1(.number(hour_2),.param(compare && (position == 2'b01) || ((position == 2'b01)^(need_to_flash == 1'b1)) ||(need_to_flash == 1'b0)),.CLK(CLK),.digit(led2));
//    num_module nm2(.number(min_1),.param(compare && (position == 2'b10)  || ((position == 2'b10)^(need_to_flash == 1'b1)) ||(need_to_flash == 1'b0)),.CLK(CLK),.digit(led3));
//    num_module nm3(.number(min_2),.param(compare && (position == 2'b11)  || ((position == 2'b11)^(need_to_flash == 1'b1)) ||(need_to_flash == 1'b0)),.CLK(CLK),.digit(led4));
endmodule
    
module lab_clock(
    input CLK,
    input reset,
    input set_time,
    input position_bt,
    input change_bt,
    output reg[6:0]led1,
    output reg[6:0]led2,
    output reg[6:0]led3,
    output reg[6:0]led4,
    output logic mid_dot
    );
    reg [3:0] state;
    reg [3:0]number1;
    reg [3:0]number2;
    reg [3:0]number3;
    reg [3:0]number4;
    reg need_to_fl;
    reg [1:0]pos;
    wire compare;
    logic mid_d; 
    assign state = reset*8 + set_time*4 + position_bt*2 + change_bt;
    
    main_clock mc(.CLK(CLK),.state(state),.compare(compare),.pos(pos),.number1(number1),.number2(number2),.number3(number3),.number4(number4),.mid_d(mid_d),.need_to_fl(need_to_fl));
    assign mid_dot = mid_d;
    num_module nm0(.number(number1),.param(compare && (pos == 2'b00) || ((pos == 2'b00)^(need_to_fl == 1'b1)) ||(need_to_fl == 1'b0)),.CLK(CLK),.digit(led1));
    num_module nm1(.number(number2),.param(compare && (pos == 2'b01) || ((pos == 2'b01)^(need_to_fl == 1'b1)) ||(need_to_fl == 1'b0)),.CLK(CLK),.digit(led2));
    num_module nm2(.number(number3),.param(compare && (pos == 2'b10)  || ((pos == 2'b10)^(need_to_fl == 1'b1)) ||(need_to_fl == 1'b0)),.CLK(CLK),.digit(led3));
    num_module nm3(.number(number4),.param(compare && (pos == 2'b11)  || ((pos == 2'b11)^(need_to_fl == 1'b1)) ||(need_to_fl == 1'b0)),.CLK(CLK),.digit(led4));
    
endmodule
   