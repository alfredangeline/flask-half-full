#define TEST_BUFFER_SIZE 16

#define UARTLITE_DEVICE_ID	XPAR_UARTLITE_0_DEVICE_ID

#include <stdio.h>
#include "xbram.h"
#include "platform.h"
#include "xil_printf.h"
#include "xparameters.h"
#include "xstatus.h"
#include "xuartlite.h"
#include "microblaze_sleep.h"

#define BRAM_DEVICE_ID		XPAR_BRAM_2_DEVICE_ID

XUartLite UartLite; /* Instance of the UartLite Device */
XBram Bram; /* The Instance of the BRAM Driver */
u8 buff[TEST_BUFFER_SIZE];

int main() {
	int Status;
	unsigned int SentCount;
	init_platform();
	XBram_Config *ConfigPtr;

	ConfigPtr = XBram_LookupConfig(BRAM_DEVICE_ID);
	if (ConfigPtr == (XBram_Config *) NULL) {
		return XST_FAILURE;
	}

	Status = XBram_CfgInitialize(&Bram, ConfigPtr, ConfigPtr->CtrlBaseAddress);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	Status = XUartLite_Initialize(&UartLite, UARTLITE_DEVICE_ID);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	u8 testbuff[TEST_BUFFER_SIZE] = { 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h',
			'1', '2', '3', '4', '5', '6', '7', '8' };
	u32 addr = Bram.Config.MemBaseAddress;
	u8 cnt = 0;
	while (cnt < TEST_BUFFER_SIZE) {
		XBram_Out8(addr, testbuff[cnt]);
		addr += 4;
		cnt++;
		usleep(100);
	}

	addr = Bram.Config.MemBaseAddress;
	cnt = 0;
	while (cnt < TEST_BUFFER_SIZE) {
		buff[cnt] = XBram_In8(addr);
		cnt++;
		addr += 4;
		usleep(100);
	}

	while (1) {
		SentCount = XUartLite_Send(&UartLite, buff, TEST_BUFFER_SIZE);
		if (SentCount != TEST_BUFFER_SIZE) {
			return XST_FAILURE;
		}
		usleep(1000);
	}

	cleanup_platform();
	return 0;
}
