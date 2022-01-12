#ifndef __B_H_

#define __B_H_

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <iostream>
#include <sstream>
#include <chrono>
#include <ctime>
#include <ncurses.h>
#include <unistd.h> 
///gpio
#include <termios.h>
#include <time.h>
#include <sys/time.h>
#include <unistd.h>
#include <errno.h>
#include <unistd.h>
#include <fcntl.h>
#include <poll.h>
//V4L2
#include <sys/ioctl.h>
#include <sys/mman.h>
#include <linux/videodev2.h>

#define VIDEO_DEVICE "/dev/video0"
#define SENSOR_COLORFORMAT V4L2_PIX_FMT_SRGGB12


#ifdef __cplusplus
extern "C" {
#endif

int gst_pipeline(void);
//read_ini
extern char buffIni[40];
extern int IMAGE_WIDTH;
extern int IMAGE_HEIGHT;
extern int IMAGE_SIZE;
int ini_gets(const char *Section, const char *Key, const char *DefValue, char *Buffer, int BufferSize, const char *Filename);

#ifdef __cplusplus
}
#endif

#endif
