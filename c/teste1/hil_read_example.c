//////////////////////////////////////////////////////////////////
//
// hil_read_example.c - C file
//
// This example reads one sample immediately from four analog input channels,
// four encoder input channels and four digital input channels.
//
// This example demonstrates the use of the following functions:
//    hil_open
//    hil_read
//    hil_close
//
// Copyright (C) 2008 Quanser Inc.
//////////////////////////////////////////////////////////////////
    
#include "hil_read_example.h"
#include "stdio.h"
#include "windows.h"

int main(int argc, char* argv[])
{
    static const char  board_type[]      = "q8_usb";
    static const char board_identifier[] = "0";
    static char        message[512];

    qsigaction_t action;
	t_card board;
    t_int  result;

    /* Prevent Ctrl+C from stopping the application so hil_close gets called */
    action.sa_handler = SIG_IGN;
    action.sa_flags   = 0;
    qsigemptyset(&action.sa_mask);

    result = hil_open(board_type, board_identifier, &board);
    if (result == 0)
    {
		printf("Placa Acessada \n");
		const t_uint32 analog_channels[] = {0, 1};
		#define NUM_ANALOG_CHANNELS     ARRAY_LENGTH(analog_channels)
		t_double  voltages[NUM_ANALOG_CHANNELS];

		result = hil_read_analog(board, analog_channels, NUM_ANALOG_CHANNELS, &voltages[0]);

		if (result >= 0)
		{
			t_uint32 channel;
			for (channel = 0; channel < NUM_ANALOG_CHANNELS; channel++)
				printf("ADC #%d: %7.4f   ", analog_channels[channel], voltages[channel]*6.25);
			printf("\n");

		} 
		else {
			printf("Erro ao ler canais!\n");
		}
            
        hil_close(board);
    }
    else
	{
        printf("Unable to open board\n");
    }

    printf("\nPress Enter to continue.\n");
    getchar();

	return 0;
}
