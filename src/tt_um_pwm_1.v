
module tt_um_pwm_1 #(
  parameter width = 8
  )  (
  input rst_n,
  input clk,
  input rst,
  input [7:0] ui_in,
  input wire ena,
  input wire [7:0] uio_in,
  output wire [7:0] uo_out,
  output wire [7:0] uio_out,
  output wire [7:0] uio_oe,
  
  output pwm_o
);

reg [31:0] q_reg, q_next;  // Registro para el contador del preescalado
reg [7:0] d_reg, d_next;   // Registro para el contador del ciclo de trabajo
reg [8:0] d_ext;           // Extensión del contador del ciclo de trabajo
reg pwm_reg, pwm_next;     // Registro y próximo valor de la señal de PWM
wire tick;                 // Señal para indicar el inicio de un ciclo PWM
wire [31:0] dvsr = 32'b00000000000000000010100010110001; // Valor fijo de dvsr 104167 valor  10Mhz/960Ard

always @(posedge clk, posedge rst_i) begin
    if (rst_i) begin
    q_reg <= 32'b0;
    d_reg <= 8'b0;
    pwm_reg <= 1'b0;
    end else begin
    q_reg <= q_next;
    d_reg <= d_next;
    pwm_reg <= pwm_next;
    end
end

// "prescaler" counter (Contador de preescalado)
always @(posedge clk) begin
  if (q_reg == dvsr) begin
    q_next <= 32'b0;
  end else begin
    q_next <= q_reg + 1;
  end
end

assign tick = (q_reg == 32'b0);

// duty cycle counter (Contador del ciclo de trabajo)
always @(posedge clk) begin
  if (tick) begin
    d_next <= d_reg + 1;
  end else begin
    d_next <= d_reg;
  end
end

always @(*) begin
  d_ext = {1'b0, d_reg};
end

// comparison circuit (Circuito de comparación para generar PWM)
always @(*) begin
  if (d_ext < ui_in) begin
    pwm_next = 1'b1;
  end else begin
    pwm_next = 1'b0;
  end
end

assign pwm_o = pwm_reg;

endmodule
