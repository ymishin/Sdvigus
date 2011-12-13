#!/bin/bash
# ***************************************************
# LSF script to run the job on the ETH Brutus cluster
# tested with MATLAB 2009b                       
# ***************************************************
#BSUB -J rt
#BSUB -n 4
#BSUB -W 1:00
#BSUB -R "rusage[mem=2000]"

export OMP_NUM_THREADS=4
export VERBOSE=2
export MODEL="`pwd`"
export SDVIGUS="/cluster/home/erdw/ymishin/sdvigus"

cd $SDVIGUS
matlab -nodisplay -r sdvigus_preproc\(\'$MODEL\',$VERBOSE,1\)
matlab -nodisplay -r sdvigus_simulator\(\'$MODEL\',$VERBOSE,$OMP_NUM_THREADS,1\)
