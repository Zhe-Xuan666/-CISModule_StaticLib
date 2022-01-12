#include "b.h"
#include <cuda.h>
#include <cuda_runtime.h>
#include <iostream>

void PTWDSP_check_memory_usage()
{
	size_t free;
	size_t total;
	cudaMemGetInfo(&free, &total);
	size_t used = total - free;
	std::cout << "Xavier momory usage:used = " << used / (1024 * 1024) << " MB, " << "free = " << free / (1024 * 1024) << " MB, " << "total = " << total / (1024 * 1024) << " MB " << std::endl;
}

void read_raw_file_16_int(char *filename, unsigned short *bitmap_data, long *width, long *heigth, int header)
{
	FILE *fp_raw;
	long  x, y;
	char *ptr;
	//header表示有無標頭
	fp_raw = fopen(filename, "rb");
	
	if (fp_raw == NULL) {
		exit(-1);
	}

	ptr = (char *)bitmap_data;
	if (header == 1) for (int i = 0; i < 16; i++) fgetc(fp_raw);

	for (y = 0; y < *heigth; y++) {
		for (x = 0; x < *width * 2; x++) {
			ptr[y*(*width) * 2 + x] = fgetc(fp_raw);
		}
	}

	fclose(fp_raw);
}

void write_raw_file(char *filename, unsigned short *bitmap_data, long *width, long *heigth)
{
     FILE *fp_raw;
     long  x, y;
     char *ptr;
     char hdr_str[20];
     fp_raw = fopen(filename, "wb");
     if (fp_raw == NULL) {
         exit(-1);
     }

     memset((char *)hdr_str, 0, 20);
     hdr_str[8] = *width % 256;
     hdr_str[9] = (int)*width / 256;
     hdr_str[12] = *heigth % 256;
     hdr_str[13] = (int)*heigth / 256;
     fwrite(hdr_str, 1, 16, fp_raw);

     ptr = (char *)bitmap_data;

     for (y = 0; y < *heigth; y++) {
         for (x = 0; x < *width * 2; x++) {
              fputc(ptr[y*(*width) * 2 + x], fp_raw);
         }
     }
     fclose(fp_raw);
}


__global__ void CalcImageConvolution(int mode, unsigned short *h_Result, unsigned short *h_Data, int *h_Kernel, long dataH, long dataW, long kernelH, long kernelW, long kernelY, long kernelX)
{
	int	x, y, kx, ky, dx, dy;
	double	sum;
	float	normalize_factor;

	int i = blockDim.x * blockIdx.x + threadIdx.x;
	if (i < dataH*dataW) {
		sum = 0.0;
		x = i % dataW;
		y = (int)(i / dataW);

		normalize_factor = (float)(kernelH * kernelW);

		for (ky = -(kernelH - kernelY - 1); ky <= kernelY; ky++) {
			for (kx = -(kernelW - kernelX - 1); kx <= kernelX; kx++) {
				dy = y + ky;
				dx = x + kx;
				if (dy < 0) sum += 0;
				else if (dx < 0) sum += 0;
				else if (dy >= dataH) sum += 0;
				else if (dx >= dataW) sum += 0;
				else sum += ((double)h_Data[dy * dataW + dx]) * ((double)h_Kernel[(kernelY + ky) * kernelW + (kernelX + kx)]);
				
			}
		}
		
		if (mode == 1) h_Result[y * dataW + x] = (unsigned short)(sum);
		else		  h_Result[y * dataW + x] = (unsigned short)((double)(sum / normalize_factor));
	}
}

void CalcImageConvolution_cuda(unsigned short *data,long w,long h){
	long kernelH, kernelW, kernelY, kernelX;
	unsigned short *kernel, *result;
	unsigned short *data_g, *result_g;
	int *kernel_g;
	kernelH = 3;
	kernelW = 3;
	kernelX = 1;
	kernelY = 1;
	
	//data = (unsigned short *)malloc(w*h * sizeof(unsigned short));
	kernel = (unsigned short *)malloc(w*h * sizeof(unsigned short));
	result = (unsigned short *)malloc(w*h * sizeof(unsigned short));
	PTWDSP_check_memory_usage();
	/*
	unsigned short kernel_3X3[] = { 1, 1, 1, 
					1, 1, 1,
					1, 1, 1};
	*/
	int kernel_3X3[] = { 1, 0, -1,
			     2, 0, -2,
			     1, 0, -1 };
	cudaMalloc((void**)&data_g, w*h * sizeof(unsigned short));
	cudaMalloc((void**)&kernel_g, kernelH*kernelW * sizeof(int));
	cudaMalloc((void**)&result_g, w*h * sizeof(unsigned short));
	// Invoke kernel
	int threads_no=512;
	int threadsPerBlock = threads_no;
	int blocksPerGrid = (h*w + threadsPerBlock - 1) / threadsPerBlock;
	cudaMemcpy(data_g, data, h * w * sizeof(unsigned short), cudaMemcpyHostToDevice);
	cudaMemcpy(kernel_g, kernel_3X3, 3 * 3 * sizeof(int), cudaMemcpyHostToDevice);
	write_raw_file((char *)"NTUST_Xavier_test.raw", (unsigned short *)data, (long *)&w, (long *)&h);	
	//write_raw_file((char *)"reverse.raw", (unsigned short *)data2, (long *)&w, (long *)&h);	
	CalcImageConvolution<<<blocksPerGrid,threadsPerBlock>>>(1, result_g, data_g, kernel_g, h, w, kernelH, kernelW, kernelY, kernelX);
	
	cudaMemcpy(result, result_g, h * w * sizeof(unsigned short), cudaMemcpyDeviceToHost);	
	write_raw_file((char *)"NTUST_Xavier_test_con.raw", (unsigned short *)result, (long *)&w, (long *)&h);
	cudaFree(data_g);
	cudaFree(kernel_g);
	cudaFree(result_g);
	//free(data);
	free(kernel);
	free(result);

}
