#include "myFuncts.h"

bool initFuncts(char* _iniFile)
{
    if(ini_gets("RESOLUTION","Width","2592",buffIni,5,iniFile))
    {
        IMAGE_WIDTH=atoi(buffIni);
    }
    else
    {
        puts("Can't set parameter Width");
        return false;
    }

    if(ini_gets("RESOLUTION","Height","1944",buffIni,5,iniFile))
    {
        IMAGE_HEIGHT=atoi(buffIni);
    }
    else
    {
        puts("Can't set parameter Height");
        return false;
    }
    if(ini_gets("RESOLUTION","Size","10077696",buffIni,10,iniFile))
    {
        IMAGE_SIZE=atoi(buffIni);
    }
    else
    {
        puts("Can't set parameter Size");
        return false;
    }

    
    return true;
}
