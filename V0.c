#include <stdio.h>
#include <stdlib.h>
#include "auxiliary.h"
#include <math.h>
#include <stdbool.h>

#define PIXELS 64 // meaning image with 64x64 pixels
#define filtSigma 0.02
#define patchSize 3
#define patchSigma 3

float comparison(int i, int j, float *G);
float compute_weight(int i, int j, float *G);
float * gaussian();

//! global variables
float *image;
int padding = patchSize / 2;

float *nonLocalMeans(){

/*
     ##############################
                V0 START
     ##############################
*/
    int row_size = PIXELS + 2*padding;

    //                original image  +  padding around the image
    int padded_size = PIXELS*PIXELS + 4*(padding*PIXELS+ padding *padding);
    int n = PIXELS * PIXELS;
    float * f_image = (float *)malloc(padded_size*sizeof(float));
    for(int i=0; i<padded_size; i++)
        f_image[i] = (float)-1;
    if(f_image == NULL){
        printf("Error.\n");
        exit(1);
    }

    // calculate the 2D gaussian kernel only once
    float *G = gaussian();

    // for each filtered pixel
    for(int r1=padding; r1<PIXELS+padding; r1++){
        for(int i=padding; i<PIXELS+padding; i++){

            f_image[r1*row_size + i] = 0;
            float Z = 0;
            float w = 0;

            // calculate: Z, w by iterating through all the pixels
            for(int r2=padding; r2<PIXELS+padding; r2++){
                for(int j=padding; j<PIXELS+padding; j++){

                    w = compute_weight(r1*row_size+i, r2*row_size+j, G);
                    Z += w;
                    f_image[r1*row_size+i] += w * image[r2*row_size+j];

                }
            }
            f_image[r1*row_size+i] = f_image[r1*row_size+i] / Z;
        }
    }

/*
     ##############################
                 V0 END
     ##############################
*/
    return f_image;
}

int main(){


    //! Read txt and convert it into a C array
    int padded_size = PIXELS*PIXELS + 4*(padding*PIXELS+ padding *padding);
    image = read_txt(PIXELS, padding);


    struct timespec tic;
    clock_gettime( CLOCK_MONOTONIC, &tic);

    //! Non-Local-Means
    image = nonLocalMeans();

    struct timespec toc;
    clock_gettime( CLOCK_MONOTONIC, &toc);
    printf("\n   ******************************\n     V0 duration = %f sec\n   ******************************\n\n",time_spent(tic, toc));




    //! Convert C array into a txt
    FILE *f = fopen("filtered_image.txt", "w");
    int counter = 0;
    for(int i=(PIXELS*padding+2*padding*padding); i<padded_size - (PIXELS*padding+2*padding*padding); i++){
        if(image[i] == (float)-1)
            continue;
        fprintf(f, "%f ", image[i]);
        counter++;
        if(counter == PIXELS){
            counter = 0;
            fprintf(f, "\n");
        }
    }
    fclose(f);
    free(image);
    return 0;
}


//! Compares Patch i and Patch j
float comparison(int i, int j, float *G){
    float comparison = 0;
    for(int k=0; k<patchSize; k++){
        for(int l=0; l<patchSize; l++){
            if(image[i+(k-padding)*(PIXELS+2*padding)+  l-padding] != (float)-1 && image[j+(k-padding)*(PIXELS+2*padding) + l-padding] != (float)-1){
                float diff = image[i+ (k-padding)*(PIXELS+2*padding)+  l-padding] - image[j + (k-padding)*(PIXELS+2*padding) + l-padding];
                comparison += G[k*patchSize+l] * diff * diff;
            }
        }
    }
    return comparison;
}


//! Computes the w(i,j)
float compute_weight(int i, int j, float *G){
    return (float)(exp(-comparison(i, j, G)/(float)(filtSigma*filtSigma)));
}

//! Compute the gaussian filter
float * gaussian(){
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


