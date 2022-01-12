#include "b.h"
#include "myFuncts.h"

//read_ini
char buffIni[40];
char iniFile[20];

int IMAGE_WIDTH;
int IMAGE_HEIGHT;
int IMAGE_SIZE;

int main(int argc, char* argv[])
{
    if(argc>1)
    {
        strcpy(iniFile,argv[1]);
    }
    else
    {
        strcpy(iniFile,"config.ini");
    }

    if(!initFuncts(iniFile))
    {
        puts("initFuncts error");
        return EXIT_FAILURE;
    }

    puts("initFuncts OK");

    //printf("Setting Cam_Width %i\n", IMAGE_WIDTH);
    //printf("Setting Cam_Height %i\n", IMAGE_HEIGHT);
    //printf("Setting IMAGE_SIZE %i\n", IMAGE_SIZE);
    
    gst_pipeline();

    return EXIT_SUCCESS;
}
