;==================== CAR CONTROL ========================

b_test					equ 0
poll_mask				equ 07h			;0Fh

;---- I2C -------------
i2c_addr_wr			equ	40h
i2c_addr_rd			equ	41h

;---- MOST ------------
FBlockID				equ	31h

nah							equ	01h					;2G 01h  3G 05h  
nal							equ	01h					;2G 01h  3G 0Eh
for_cmd_1012		equ	05h					;2G 05h  3G 01h

uart_head_h			equ	0ABh
uart_head_l			equ	0BAh

task_mode_most	equ	9Ah
task_mode_uart	equ	uart_head_l
task_mode_int		equ	9Ch

ack_ok					equ	00h
ack_error				equ	01h

ir_addr_				equ 0C0h+19h		

ir_command_play			equ  40h 	;00h
ir_command_pause		equ	 80h		;01h
ir_command_next			equ	 10h		;02h
ir_command_prev			equ	 20h		;03h
ir_command_answer		equ  10h   ;08h 
ir_command_ignore		equ  20h		;09h
ir_command_pairing	equ	0C0h	;
ir_command_mix_on		equ	 90h	;90
ir_command_mix_off	equ	0A0h	;A0

ir_command_ff				equ	 00h		;04h
ir_command_rew			equ	 00h   ;05h
ir_command_ff_rel		equ	 00h   ;06h
ir_command_rew_rel	equ	 00h   ;07h

aux_prev_next_timer		equ 10

line_lenght						equ	21
run_line_timer_long_1	equ	20
run_line_timer_long_2	equ	12
run_line_timer_short	equ 2	

request_sync_delay		equ	4
request_sync_start		equ	20	
send_mix_delay				equ 10

;-----------�������� OS8104 � ������� ���������� (�������� ����� ������)
bXSR_reset	equ	50h		;reg 81h
bMSGC_reset	equ	00h		;reg 85h