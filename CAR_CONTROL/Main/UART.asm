
;----------UART--------------------------

$include(c8051f340.inc)	; Файлы с определениями для МК
$include(CONSTANT.inc)
$include(MEMORY.inc)
$include(MCU_IO.inc)

public	UART_TX

public	UART0_INT

;-------------------------------------------------------------------

UART_CODE 	segment code
    				rseg UART_CODE

;===========================================================================

UART_RX:			
				MOV		DPTR,#UART_RX_STATUS_				
				MOV		A,uart_rx_status
				RL		A
				ANL		A,#0Fh
				JMP	@A+DPTR	

UART_RX_STATUS_:		
				AJMP	UART_RX_00					;Ожидание старшего байта заголовка
				AJMP	UART_RX_01					;Ожидание младшего байта заголовка
				AJMP	UART_RX_02					;Ожидание команды
				AJMP	UART_RX_03					;Ожидание старшего байта размера данных
				AJMP	UART_RX_04					;Ожидание младшего байта размера данных
				AJMP	UART_RX_05					;Ожидание данных
				AJMP	UART_RX_06					;Ожидание контрольной суммы

;-------Сброс после приема или в случае сбоя
UART_RESET:
				MOV		uart_rx_status,#00h
				MOV		uart_crc,#00h
				RET

;-------Ожидание старшего байта заголовка	
UART_RX_00:
				MOV		A,SBUF0	
				CJNE	A,#uart_head_h,UART_RESET

				MOV		uart_rx_status,#01h
				
				ACALL	CRC_RX
				
				ACALL	START_BUF_RX
				
				ACALL	DATA_RX

				RET

;-------Ожидание младшего байта заголовка		
UART_RX_01:
				MOV		A,SBUF0	
				CJNE	A,#uart_head_l,UART_RESET

				MOV		uart_rx_status,#02h
				
				ACALL	CRC_RX
				
				ACALL	DATA_RX		
				
				RET

;-------Ожидание команды
UART_RX_02:
				MOV		uart_rx_status,#03h
				
				ACALL	CRC_RX
				
				ACALL	DATA_RX

				RET

;-------Ожидание старшего байта размера данных
UART_RX_03:
				MOV		uart_rx_status,#04h				

				ACALL	CRC_RX
				
				ACALL	DATA_RX

				MOV		uart_size_h,SBUF0
				
				RET

;-------Ожидание младшего байта размера данных
UART_RX_04:
				MOV		uart_rx_status,#05h

				ACALL	CRC_RX
				
				ACALL	DATA_RX
				
				MOV		uart_size_l,SBUF0
				MOV		A,uart_size_l
				ORL		A,uart_size_h
				JNZ		UART_RX_04_EXIT
				
				MOV		uart_rx_status,#06h				

UART_RX_04_EXIT:
				RET

;-------Ожидание данных
UART_RX_05:
				ACALL	CRC_RX
				ACALL	DATA_RX
				RET

;-------Ожидание контрольной суммы
UART_RX_06:
				MOV		uart_rx_status,#00h

				MOV		A,SBUF0
				CJNE	A,uart_crc,UART_RX_ERROR

				SETB	b_uart_rx
				
				MOV		uart_crc,#00h
				RET
UART_RX_ERROR:
				MOV		SBUF0,#ack_error
				AJMP	UART_RESET
				;RET

;-------Начальный адрес буфера приема
START_BUF_RX:
				MOV		DPTR,#uart_rx_buffer
				MOV		uart_buf_addr_h,DPH
				MOV		uart_buf_addr_l,DPL
				MOV		uart_size_h,#0FFh
				MOV		uart_size_l,#0FFh
				RET

;-------Вычисление CRC
CRC_RX:
				MOV		A,SBUF0
				ADD		A,uart_crc
				MOV		uart_crc,A
				RET

;-------Прием данных в буфер
;   <-> uart_size_h, uart_size_l
;   <-> uart_buf_addr_h, uart_buf_addr_l
;   --> SBUF0
;   <-- uart_rx_buffer (XDATA)
;   <-- uart_rx_status
DATA_RX:
				MOV		DPH,uart_buf_addr_h
				MOV		DPL,uart_buf_addr_l

				MOV		A,SBUF0
				MOVX	@DPTR,A
				INC		DPTR

				MOV		uart_buf_addr_h,DPH
				MOV		uart_buf_addr_l,DPL
				
				DJNZ	uart_size_l,RECEIVE_EXIT

				MOV		A,uart_size_h
				JZ		RECEIVE_END

				DEC		uart_size_h
				AJMP	RECEIVE_EXIT
						
RECEIVE_END:
				MOV		uart_rx_status,#06h
RECEIVE_EXIT:
				RET				


;   --> uart_command,uart_size_tx
;   --> uart_tx_buffer (xdata)
UART_TX:
				SETB	b_wait_uart_tx

				MOV		DPTR,#uart_tx_buffer
				MOV		A,#uart_head_h
				MOVX	@DPTR,A

				INC		DPTR
				MOV		A,#uart_head_l
				MOVX	@DPTR,A

				INC		DPTR
				MOV		A,uart_command
				MOVX	@DPTR,A

				INC		DPTR
				MOV		A,#00h
				MOVX	@DPTR,A

				INC		DPTR
				MOV		A,uart_size_tx
				MOVX	@DPTR,A
				MOV		A,uart_size_tx
				ADD		A,#6
				MOV		uart_size_tx,A

				MOV		DPTR,#uart_tx_buffer
				MOVX	A,@DPTR
				MOV		SBUF0,A
				MOV		uart_buf_cnt_tx,#01h

				RET


UART_TX_NEXT:
				MOV		DPTR,#uart_tx_buffer
				MOV		DPL,uart_buf_cnt_tx
				MOV		A,uart_buf_cnt_tx
				XRL		A,uart_size_tx
				JNZ		UART_TX_NEXT_1

				CLR		b_wait_uart_tx

				RET

UART_TX_NEXT_1:
				MOVX	A,@DPTR
				MOV		SBUF0,A
				INC		uart_buf_cnt_tx	
				RET


;--------Подпрограмма обработки прерываний UART0 ---------------------

UART0_INT:		
				using 3
				PUSH	ACC
				PUSH	B
				PUSH	PSW
				PUSH	DPH
				PUSH	DPL
				PUSH	EMI0CN
				SETB	RS0							;3 банк регистров
				SETB	RS1							;

				JNB		RI0,UART0_NEXT_0
				CLR		RI0
				ACALL	UART_RX

UART0_NEXT_0:
				JNB		TI0,UART0_EXIT
				CLR		TI0
				ACALL	UART_TX_NEXT

UART0_EXIT:	
				POP   EMI0CN
				POP		DPL
				POP		DPH
				POP		PSW
				POP		B
				POP		ACC	
				RETI	

				END.