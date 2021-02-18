#include <stdio.h>
#include <stdlib.h>
#include "auxiliary.h"
#include <math.h>
#include <stdbool.h>

#define PIXELS 64 // meaning image with PIXELSxPIXELS pixels
#define filtSigma 0.02
#define patchSize 3
#define patchSigma 3
__device__ void comparison(float *comparison,int i, int j, float *G, float *image);
__device__ void compute_weight(float *w, int i, int j, float *G, float *image);
__host__ float * gaussian();
__global__ void compute_f_pixel(float *f_image,float *image, int padded_size, float *G);

//! global variables
__device__ const int dev_PIXELS = PIXELS;
__device__ const float dev_filtSigma = (float)filtSigma;
__device__ const int dev_patchSize = patchSize;
__device__ const int dev_padding = patchSize/2;



__host__ float *nonLocalMeans(float *host_image){

/*
     ##############################
                V1 START
     ##############################
*/

	int padding = patchSize/2;
    int n = PIXELS * PIXELS;
	int padded_size = n + 4*(padding*PIXELS+ padding *padding);
	
	// Creation of Gaussian Filter
    float *G;
	cudaMallocManaged(&G, patchSize*patchSize*sizeof(float));
	if(G == NULL){
        printf("Error.\n");
        exit(1);
    }
	float *temp_G = gaussian();
	memcpy(G,temp_G,patchSize*patchSize*sizeof(float));
	
	// Have a copy of the original in cuda memory
	float *image;
	cudaMallocManaged(&image, padded_size*sizeof(float));
	if(image == NULL){
        printf("Error.\n");
        exit(1);
    }
	memcpy(image,host_image, padded_size*sizeof(float));

	// Creation of filtered image C array
	float *f_image;
	cudaMallocManaged(&f_image, padded_size*sizeof(float));
	if(f_image == NULL){
        printf("Error.\n");
        exit(1);
    }
	for(int i=0; i<padded_size; i++)
		f_image[i]=(float)-1;
	
	
	// Creation of the kernel
    compute_f_pixel<<<PIXELS,PIXELS>>>(f_image,image, padded_size, G);
	cudaDeviceSynchronize();
	
	cudaFree(G);
	free(temp_G);
	cudaFree(image);
/*
     ##############################
                 V1 END
     ##############################
*/
    return f_image;
}


__global__ void compute_f_pixel(float *f_image,float *image, int padded_size, float *G){
	
	// index i is calculated so that it iterates the original image minus the padding
	int i = blockIdx.x*(blockDim.x+2*dev_padding)+(threadIdx.x+dev_padding) + dev_padding*dev_PIXELS+2*dev_padding*dev_padding;
	
	if(i < padded_size){
		f_image[i] = 0;
		float Z = 0;
		float w;
		
		for(int r=dev_padding; r<dev_PIXELS+dev_padding; r++){
            for(int j=dev_padding; j<dev_PIXELS+dev_padding; j++){
				compute_weight(&w, i, r*(dev_PIXELS+2*dev_padding)+j, G, image);
				Z += w;
				f_image[i] += w * image[r*(dev_PIXELS+2*dev_padding)+j];
			}
		}
		f_image[i] = f_image[i] / Z; 
	}
}

__host__ int main(){
	
	// Convert txt to C array
	int padding = patchSize/2;
    float *host_image = read_txt(PIXELS, padding);
	float *f_image;
	cudaMallocManaged(&f_image,0);
	
	
    struct timespec tic;
    clock_gettime( CLOCK_MONOTONIC, &tic);

	// Non-Local-Means
    f_image = nonLocalMeans(host_image);
	
    struct timespec toc;
    clock_gettime( CLOCK_MONOTONIC, &toc);
    printf("\n   ******************************\n     V1 duration = %f sec\n   ******************************\n\n",time_spent(tic, toc));

	
	// Convert C array to txt
	int padded_size = PIXELS*PIXELS + 4*(padding*PIXELS+ padding *padding);
    FILE *f = fopen("filtered_image_V1.txt", "w");
    int counter = 0;
    for(int i=(PIXELS*padding+2*padding*padding); i<padded_size - (PIXELS*padding+2*padding*padding); i++){
        if(f_image[i] == (float)-1)
            continue;
        fprintf(f, "%f ", f_image[i]);
        counter++;
        if(counter == PIXELS){
            counter = 0;
            fprintf(f, "\n");
        }
    }
    fclose(f);
    free(host_image);
	cudaFree(f_image);
    return 0;
}


//! Compares Patch i and Patch j
__device__ void comparison(float *comparison_value,int i, int j, float *G, float *image){
    for(int k=0; k<dev_patchSize; k++){
        for(int l=0; l<dev_patchSize; l++){
            if(image[i+(k-dev_padding)*(dev_PIXELS+2*dev_padding)+  l-dev_padding] != (float)-1 && image[j+(k-dev_padding)*(dev_PIXELS+2*dev_padding) + l-dev_padding] != (float)-1){
                float diff = image[i+(k-dev_padding)*(dev_PIXELS+2*dev_padding)+  l-dev_padding] - image[j+(k-dev_padding)*(dev_PIXELS+2*dev_padding) + l-dev_padding];
                *comparison_value += G[k*dev_patchSize+l] * diff * diff;
            }
        }
    }
}


//! Computes the w(i,j)
__device__ void compute_weight(float *w, int i, int j, float *G, float *image){
	float comparison_value = 0;
	comparison(&comparison_value, i, j, G, image);
	*w = (float)(exp(-comparison_value/(dev_filtSigma*dev_filtSigma)));
}

//! Compute the gaussian filter
__host__ float * gaussian(){
    float *G = (float *)malloc(patchSize*patchSize*sizeof(float));
	if(G == NULL){
            printf("Error.\n");
            exit(1);
        }
    int bound = patchSize/2;
    for(int x=-bound; x<=bound; x++){ // if patchSize=5 then x = -2,-1,0,+1,+2
        for(int y=-bound; y<=bound; y++){
            float G_temp = exp(-(float)(x*x+y*y)/(float)(2*patchSigma*patchSigma))/(float)(2*M_PI*patchSigma*patchSigma); // 2D Gaussian filter
            int i = (x+bound)*patchSize +(y+bound); // i = 0*5+{0,1,2,3,4}, 1*5+{0,1,2,3,4},..., 4*5+{0,1,2,3,4}
            G[i] = G_temp;
        }
    }
    return G;
}

