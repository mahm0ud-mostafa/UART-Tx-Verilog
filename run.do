transcript on

if {![file exists work]} {
    vlib work
}

vlog serializer.v parity_calc.v mux.v main_controller.v UART_TX.v

vlog serializer_tb.v parity_calc_tb.v mux_tb.v main_controller_tb.v UART_TX_tb.v

vsim -voptargs=+acc -onfinish stop work.UART_TX_tb

add wave -r sim:/UART_TX_tb/*

run -all

wave zoom full