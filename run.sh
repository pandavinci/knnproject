#!/bin/bash
#PBS -q gpu
#PBS -N KNN-StarGAN
#PBS -l select=1:ncpus=1:ngpus=1:gpu_mem=10gb:mem=8gb:scratch_local=100gb
#PBS -l walltime=24:00:00
#PBS -m ae

## Author: Zbyněk Lička

#### VARIABLES ####
export TASK="stargan_knn"

export SRCDIR=/storage/brno2/home/${USER}/${TASK}
test -n "$SCRATCHDIR" || { echo >&2 "Variable SCRATCHDIR is not set!"; exit 1; } # Taken from metacentrum documentation
export TMPDIR=$SCRATCHDIR

echo "$PBS_JOBID is running on node `hostname -f` in a scratch directory $SCRATCHDIR" >> $SRCDIR/jobs_info.txt # Taken from metacentrum documentation

#### MODULES ####
echo "Loading modules at $(date)"
module add anaconda3/2019.10
module add cuda/8.0

cd /storage/brno12-cerit/home/${USER}/
source activate .conda/envs/${TASK}

#### SCRATCH ####
cd ${SCRATCHDIR}

cp -r ${SRCDIR} ${SCRATCHDIR}
cd ${TASK}

#### DATA GENERATION ####
echo "Training started at $(date)"
python3 train.py || { echo >&2 "Calculation ended up erroneously (with a code $?) !!"; exit 3; } # output check taken from metacentrum documentation

#### COPY RESULTS ####
echo "Copying results at $(date)"
cp -r Models/ ${SRCDIR} || { echo >&2 "Result file(s) copying failed (with a code $?) !!"; exit 4; } # output check taken from metacentrum documentation

echo "Job finished at $(date)"
clean_scratch
