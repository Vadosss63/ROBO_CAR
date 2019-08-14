;==================== CAR CONTROL ========================

$include(C8051F310.inc)
$include(CONSTANT.inc)
$include(MEMORY.inc)
$include(MCU_IO.inc)

extrn 		code(INIT_DEVICE)
extrn			code(UART0_INT)
extrn			code(UART_TX)

;=====================================================

				cseg	at 0

;-------Векторы прерываний----------------------------

				org		0000h					;Reset
				LJMP	RESET_INT

				org		0023h					;UART0
				LJMP	UART0_INT

RESET_INT:
				CLR		EA						;Запретить прерывания
				MOV		SP,#STACK			;Инициализация указателя стека

				LCALL	INIT_DEVICE		;Вызов процедуры конфигурации МК

;-------Инициализация портов ввода-вывода-----						
				MOV		P0,#P0_IO
				MOV		P1,#P1_IO
				MOV		P2,#P2_IO
				MOV		P3,#P3_IO	

				CLR		bt_en						;Выключение Bluetooth

;-------Обнуление памати XDATA------------
				MOV		DPTR,#0000h
				CLR		A
XDATA_CLR:
				MOV		PCA0CPH4,#00h		;Сброс сторожевого таймера
				MOVX	@DPTR,A
				INC		DPTR
				MOV		A,DPH
				ANL		A,#08h
				JZ		XDATA_CLR

;-------Обнуление памати DATA-------------	
				MOV		R0,#0FFh
				CLR		A
DATA_CLR:	
				MOV		@R0,A
				DJNZ	R0,DATA_CLR

;==================================================
			
				MOV		PCA0CPH4,#00h			;Сброс сторожевого таймера

				SETB	EA															

;===================================================				

				SETB	bt_en							;Включение Bluetooth

;---------------------------------------------------
MAIN:	
				MOV		PCA0CPH4,#00h			;Сброс сторожевого таймера		

				ACALL	CHECK_UART_RX			;Вызов процедуры проверки UART RX		

				SJMP	MAIN	

;-------Проверка UART_RX----------------
CHECK_UART_RX:
				JB		b_uart_rx,UART_RX_DECODE		;Переход, если есть флаг b_uart_rx (принята команда)

				RET

;====================================================

;-------Дешифрация принимаемых команд UART------------------
;   --> DPTR
;   <-- EMI0CN, R0 (uart_size_h)
UART_RX_DECODE:
				CLR		b_uart_rx
				
				MOV		DPTR,#uart_rx_buffer+2			;2 байт (команда)
								
				MOVX	A,@DPTR
				
				ANL		A,#0Fh
				RL		A
				MOV		DPTR,#UART_COMMANDS
				JMP	@A+DPTR	

UART_COMMANDS:		
				AJMP	COMMAND_00
				AJMP	COMMAND_01					
				AJMP	COMMAND_02				
				AJMP	COMMAND_03					
				AJMP	COMMAND_04					
				AJMP	COMMAND_05					
				AJMP	COMMAND_06					
				AJMP	COMMAND_07		
				AJMP	COMMAND_08
				AJMP	COMMAND_09					
				AJMP	COMMAND_0A				
				AJMP	COMMAND_0B					
				AJMP	COMMAND_0C					
				AJMP	COMMAND_0D					
				AJMP	COMMAND_0E					
				AJMP	COMMAND_0F
				
;-------
COMMAND_00:	
				RET

;-------
COMMAND_01:	
				ACALL	SEND_ACK_OK
				RET
				
;-------								
COMMAND_02:
				ACALL	SEND_ACK_OK			
				RET

;-------								
COMMAND_03:
				ACALL	SEND_ACK_OK			
				RET

;-------							
COMMAND_04:			
				RET
				

;-------
COMMAND_05:
				MOV		DPTR,#uart_rx_buffer+8			;8 байт (номер трека)

				MOVX	A,@DPTR

				MOV		C,ACC.0
				MOV		LED0,C
				MOV		forward,C

				MOV		C,ACC.1
				MOV		LED1,C
				MOV		backward,C

				MOV		C,ACC.2
				MOV		LED2,C
				MOV		left,C

				MOV		C,ACC.3
				MOV		LED3,C
				MOV		right,C
				
				ACALL	SEND_ACK_OK
				RET

;-------									
COMMAND_06:
				RET

;-------									
COMMAND_07:
				RET	

;-------									
COMMAND_08:
				RET

;-------									
COMMAND_09:
				RET

;-------								
COMMAND_0A:
				ACALL	SEND_ACK_OK
				RET

;-------									
COMMAND_0B:
				ACALL	SEND_ACK_OK
				RET

;-------									
COMMAND_0C:
				RET

;-------									
COMMAND_0D:
				RET

;-------									
COMMAND_0E:
				RET

;-------									
COMMAND_0F:
				RET

;-------Отправка ответа-------------
SEND_ACK_OK:
				MOV		SBUF0,#ack_ok	
				RET


				END.






