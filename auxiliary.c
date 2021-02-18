#include <stdio.h>
#include <stdlib.h>
#include <time.h>


float *read_txt(int pixels, int padding){ // pixels = 64 or 128 or 256
    int padded_size = pixels*pixels + 4*(padding*pixels+ padding *padding);
    float *image = (float *)malloc(padded_size*sizeof(float));
    if(image == NULL){
        printf("Cannot start.\n");
        return NULL;
    }
    for(int i=0; i<padded_size; i++)
        image[i] = -1;
    FILE *f = fopen("image.txt","r");
    for(int i=padding; i<(pixels+padding); i++){
        for(int j=padding; j<(pixels+padding); j++){
            if (j != pixels+padding-1){
                if(fscanf(f, "%f\t",&image[i*(pixels+(2*padding)) + j]) != 1)
                    printf("error\n");
            }
            else{
                if(fscanf(f, "%f\n",&image[i*(pixels+(2*padding)) + j]) != 1)
                    printf("error\n");
            }
        }
    }
    fclose(f);
    return image;
}


double time_spent(struct timespec start,struct timespec end_){
        struct timespec temp;
        if ((end_.tv_nsec - start.tv_nsec) < 0)
        {
                temp.tv_sec = end_.tv_sec - start.tv_sec - 1;
                temp.tv_nsec = 1000000000 + end_.tv_nsec - start.tv_nsec;
        }
        else
        {
                temp.tv_sec = end_.tv_sec - start.tv_sec;
                temp.tv_nsec = end_.tv_nsec - start.tv_nsec;
        }
        return (double)temp.tv_sec +(double)((double)temp.tv_nsec/(double)1000000000);

}

