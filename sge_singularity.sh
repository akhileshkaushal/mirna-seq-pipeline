#!/bin/bash

# do not touch these settings
#  number of tasks and nodes are fixed at 1
#$ -S /bin/sh
#$ -terse
#$ -V

# job name for pipeline
#  this name will appear when you monitor jobs with "squeue -u $USER"
#$ -N MIRNATESTENCODE

# walltime for your job
#  give long time enough to finish your pipeline
#  <12 hr: small/test samples
#  >24 hr: large samples
#$ -l h_rt=12:00:00
#$ -l s_rt=12:00:00

# total amount of memory
#  depends on the size of your FASTQs
#  but should be <= NUM_CONCURRENT_TASK x 20GB for big samples
#  or <= NUM_CONCURRENT_TASK x 10GB for small samples
#  do not request too much memory
#  cluster will not accept your job
#$ -l h_vmem=20G
#$ -l s_vmem=20G

# max number of cpus for each pipeline
#  should be >= NUM_CONCURRENT_TASK x "mirna_seq_pipeline.star" in input JSON file
#  since star is a bottlenecking task in the pipeline
#  SGE has a parallel environment (PE).
#  ask your admin to add a new PE named "shm"
#  or use your cluster's own PE instead of "shm"
#  2 means number of cpus per pipeline
#$ -pe openmp 4

# load java module if it exists
module load java || true

# use input JSON for a small test sample
#  you make an input JSON for your own sample
INPUT=

# If this pipeline fails, then use this metadata JSON file to resume a failed pipeline from where it left 
# See details in /utils/resumer/README.md
PIPELINE_METADATA=metadata.json

# limit number of concurrent tasks
#  we recommend to use a number of replicates here
#  so that all replicates are processed in parellel at the same time.
#  make sure that resource settings in your input JSON file
#  are consistent with SBATCH resource settings (--mem, --cpus-per-task) 
#  in this script
NUM_CONCURRENT_TASK=2

# run pipeline
#  you can monitor your jobs with "squeue -u $USER"
java -jar -Dconfig.file=backends/backend.conf -Dbackend.default=singularity \
-Dbackend.providers.singularity.config.concurrent-job-limit=${NUM_CONCURRENT_TASK} \
$HOME/cromwell-35.jar run mirna_seq_pipeline.wdl -i ${INPUT} -o workflow_opts/singularity.json -m ${PIPELINE_METADATA}