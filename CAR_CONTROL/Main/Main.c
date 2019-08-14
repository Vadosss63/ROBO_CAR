
#include "Config.h"
#include "MCU_IO.h"


void parsingControl();
void sendAnswer();
void RunLED();

//------------------------------------------------------------------------------//
//                               Main function                                  //
//------------------------------------------------------------------------------//
// ������������� ������
void Init_IO()
{
 	P0 = P0_IO;
 	P1 = P1_IO;
	P2 = P2_IO;
 	P3 = P3_IO;	
	//���������� Bluetooth
	BT_EN = 1;
}

void UART_RX_DECODE()
{
	b_uart_rx = 0;
	
	if(UART_Buffer[UART_CMD] == CMD_CONTROL)
	{
		parsingControl();
	}	
}

void parsingControl()
{
	char control = UART_Buffer[UART_Data + 3];
    bit cb0 = (control >> 0) & 1u;
	bit cb1 = (control >> 1) & 1u;
	bit cb2 = (control >> 2) & 1u;
	bit cb3 = (control >> 3) & 1u;
	
	LED0 = cb0;
	FORWARD = cb0;

	LED1 = cb1;
	BACKWARD = cb1;	

	LED2 = cb2;
	LEFT = cb2;
	
	LED3  = cb3;
	RIGHT = cb3;
				
	sendAnswer();
}

void sendAnswer()  
{
  SBUF0 = 0;
}

void main(void)
{
	
	PCA0MD &= ~0x40; // Disable the watchdog timer 

	Init_Device();
	Init_IO();
	EA = 1;
   //	IP |= 0x10;                         // Make UART high priority
   	ES0 = 1;                            // Enable UART0 interrupts
	while(1) {
		PCA0MD = 0x00;
		if(b_uart_rx)		
			UART_RX_DECODE();		
	};
}

#define uart_head_h 0xAB
#define uart_head_l 0xBA
static char Byte;
static int readByte = 0;
static int sizeData = 0;


char getCRC(unsigned char size)
{
	char crc = 0;
	char i;
	for (i = 0; i < size; i++)
	{
		crc += UART_Buffer[i];	
	}
	return crc;
}

int val = 0;

void UART0_Interrupt (void) interrupt 4
{
   PCA0MD &= ~0x40;
   if (TI0 == 1)                   // Check if transmit flag is set
   {
      TI0 = 0; 
   }

   if (RI0 == 1)
   {  

      RI0 = 0;                           // Clear interrupt flag
      Byte = SBUF0;                      // Read a character from UART	
	  UART_Buffer[readByte] = Byte;      // Store in array

	if(readByte == 0)
	{
		if(UART_Buffer[readByte] == uart_head_h)		
			readByte++;	

		return;
	}
    
	if(readByte == 1)
	{
		if(UART_Buffer[readByte] == uart_head_l)	
			readByte++;		
		else 
			readByte = 0;

		return;
	}

	if(readByte == 2 || readByte == 3)
	{
		readByte++;
		return;
	}

    if(readByte == 4)
	{
		sizeData = Byte;
		readByte++;
		return;
	}
	
	while(readByte < sizeData + 5)
	{
	    readByte++;	
		return;
	}

    if(readByte == sizeData + 5)
	{
		if(Byte == getCRC(readByte))	
			b_uart_rx = 1;	

	}
    readByte = 0;	      

   }
}