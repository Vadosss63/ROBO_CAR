;==================== CAR CONTROL ========================

;---------P0----------
;NC							equ	P0.0
;NC							equ	P0.1
;NC							equ P0.2
BT_EN						equ	P0.3 	 	;��������� bluetooth
UART0_TX				equ	P0.4		;UART TX
UART0_RX				equ P0.5		;UART RX
;NC							equ	P0.6
;NC							equ	P0.7
;---------P1----------
IO7							equ	P1.0		;�����-������ ��� ��������
IO6							equ P1.1		;
IO5							equ P1.2		;
IO4							equ P1.3		;
IO3							equ	P1.4		;
IO2							equ P1.5		;
IO1							equ	P1.6		;
IO0							equ P1.7		;
;---------P2----------
LED0						equ P2.0		;����������	
LED1						equ	P2.1		;
LED2						equ P2.2		;
LED3						equ P2.3		;
;NC							equ P2.4
;NC							equ P2.5
VBAT						equ P2.6		;���������� �������
LEFT						equ P2.7		;�����
;---------P3----------
;NC							equ P3.0
BT_STATUS				equ P3.1		;������ bluetooth		
FORWARD					equ P3.2		;������
BACKWARD				equ	P3.3		;�����
RIGHT						equ	P3.4		;������

;-----------����� �����-������
P0_IO				equ	0F7h
P1_IO				equ	0FFh
P2_IO				equ	070h
P3_IO				equ	0E3h