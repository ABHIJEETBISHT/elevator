module lift_2(clk,rst,flr1,flr2,flr3,up1,up2,dw3,dw2,rst_count,out_count,out);

input clk,rst,flr1,flr2,flr3,up1,up2,dw3,dw2,timeout;
output [3:0]out_count,out;
`define OPEN1 3'b000
`define CLOSE1 3'b001
//`define TIMEOUT 8'h55 //Any random timeout
//assign flr_display = out;
parameter FLOOR = 3; //Placeholder for next assignment

reg [2:0]state,out;
reg [3:0]out_count;

/*
1: assign my_clk = clk and clk_en;//assign is always outside procedural blocks (initial/always)
2: always@(*)
    my_clk = clk & clk_en

    */
//reset lift
always@(posedge clk) //Synchronous rst
//always@(posedge clk or posedge rst) //Asynchronous rst
//always@(clk,rst) //clk = True or rst = 1 //Level sensitive //latches, combination circuits
//always@(posedge clk or rst)
begin
    if(rst)
    begin
        out_count <= 0;
        state <= `OPEN1;//open1
        out <= `OPEN1; //AB: You shouldn't mix blocking and non-blocking inside a Precedural block(always) - it'll not get synthesized
    end
    //different floor conditions
    else
    begin
        case(state)//lift is in first floor
            `OPEN1: //open1
        begin
            if(rst_count) // counter start for delay
            begin
             //AB: You can avoid putting begin-end pair incase you just have one statement-it'll shorten code length
                out_count <= 0;
                rst_count <= 0;
                state <= `CLOSE1;// delay end, entered into next state i.e close1
            end
            else
                out_count <= out_count + 1;
           
            if(out_count == timeout)    
                rst_count <= 1'b1;
            //AB: This is a big mistake !!! This mistake happens when we come from Computer Programming language background to HDL. Here if(rst_count) and state <= 3'b001 are going to execute parallely and not sequenctial(like in C/C++). Think if it can cause issue in your code ?

            if(flr1 || up1 )
            begin
                state <= `OPEN1; //open1
                out <= `OPEN1;
            end

        end
        `CLOSE1: //close1
    begin//AB: 2 -begins ?
        if(flr1 || up1 )
        begin
            state <= 3'b000; //open1
            out = state;
        end
        else if(flr2 || flr3 || up2 || dw3 || dw2)
        begin
            state <= 3'b010; //close2
            out = state;
        end
    end
end
3'b010: //close2
begin
begin
    if(flr2 || up2 || dw2 )
    begin
        state <= 3'b011; //open2
        out = state;
    end
    else if(flr1 || up1)
    begin
        state <= 3'b001; //close1
        out = state;
    end
    else if(flr3 || dw3)
    begin
        state <= 3'b100; //close3
        out = state;
    end
end
end

3'b011: //open2
begin
    if(rst_count) // counter start for delay
    begin
        out_count = 0;
    end
    else
    begin
        out_count = out_count + 1;
    end
    state <= 3'b010;// delay end, entered into next state i.e close2

    if(flr2 || up2 || dw2 )
    begin
        state <= 3'b011; //open2
        out = state;
    end
end

3'b100: //close3
begin
    if(flr3 || dw3 )
    begin
        state <= 3'b101; //open3
        out = state;
    end
end

3'b101: //open3
begin
    if(rst_count) // counter start for delay
    begin
        out_count = 0;
    end
    else
    begin
        out_count = out_count + 1;
    end
    state <= 3'b100;// delay end, entered into next state i.e close3

    if(flr3 || dw3 )
    begin
        state <= 3'b101; //open3
        out = state;
    end

end
endcase
end
end
endmodule
