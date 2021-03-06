#!/bin/bash
#SBATCH -n 32
#SBATCH --time=3:00:00
#SBATCH --partition=cees
#SBATCH -o output%j.out
#SBATCH -e error%j.err

path_to_inputfiles=$SCRATCH/mborrus/code/MiMAv0.1/input

rundir=$SCRATCH/mborrus/code/MiMAv0.1/exp/exec.SE3Mazama

npes=32
num_executions=2

# stop on error
set -e

# copy input files
cp -r $path_to_inputfiles/* $rundir/

# run the model
cd $rundir
if [ ! -d RESTART ]
then
  mkdir RESTART
fi

n=0
while [ $n -lt $num_executions ]
do
  echo 'STARTING ITERATION '$n
  index=`printf %04d ${n%*} ${n##*}`
  mpiexec -n $npes ./mima.x > out.${index}.txt
  mppnccombine -r ${index}.atmos_daily.nc atmos_daily.nc.????
  mppnccombine -r ${index}.atmos_avg.nc atmos_avg.nc.????
  cp RESTART/*res* INPUT/
  echo 'DONE WITH ITERATION '$n
  let n=$n+1
done
