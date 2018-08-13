#include "hil_read_example.h"
#include "stdio.h"
#include "windows.h"

static const char  board_type[]      = "q8_usb";
static const char board_identifier[] = "0";
static t_card board;
static t_int  result;
static t_uint32 analog_channels[] = {0, 1};
#define NUM_ANALOG_CHANNELS ARRAY_LENGTH(analog_channels);

static t_double voltages[NUM_ANALOG_CHANNELS];

bool setup(const char[], const char[], t_card*);
bool ler(t_card, const t_uint32[], t_double*);
void fechar(t_card*);


int main(int argc, char* argv[])
{
    

    qsigaction_t action;


    /* Prevent Ctrl+C from stopping the application so hil_close gets called */
    action.sa_handler = SIG_IGN;
    action.sa_flags   = 0;
    qsigemptyset(&action.sa_mask);

    result = setup(board_type, board_identifier, &board);
    if (result == 0)
    {
		printf("Placa Acessada \n");
		

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
            
        fechar(board);
    }
    else
	{
        printf("Unable to open board\n");
    }

    printf("\nPress Enter to continue.\n");
    getchar();

	return 0;
}

bool setup(const char btype[], const char bident[], t_card *board){
	result = hil_open(btype, bident, &board);
	if (result == 0){
		printf("Placa Acessada \n");
		return true;
	} else {
		printf("Não foi possível acessar a placa!\n")
		return false;
	}
}

bool ler(t_card placa, const t_uint32[] canais_analogicos, t_double* voltagens){
	result = hil_analog_read(placa, canais_analogicos, NUM_ANALOG_CHANNELS, &voltagens[0]);
	if (result == 0){
		printf("Leitura completa! \n");
		return true;	
	} else {
		printf("Não foi possível ler valores!\n")
		return false;
	}
}

void fechar(t_card *board){
	hil_close(board);
}