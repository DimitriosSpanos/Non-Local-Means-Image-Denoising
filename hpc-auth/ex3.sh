#!/bin/bash
#SBATCH --job-name=gpujob
#SBATCH --nodes=1
#SBATCH --partition=gpu
#SBATCH --gres=gpu:1
#SBATCH --time=10:00
#SBATCH --output=durations.stdout 


module load gcc
module load cuda/10.1.243

#nvidia-smi
make clean
make all
./V0
./V1
./V2
make clean



