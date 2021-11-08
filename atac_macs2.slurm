#!/bin/bash
#!/bin/bash
#SBATCH --time=2:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mem=30G
#SBATCH --cpus-per-task=8 
#SBATCH -o log/slurmjob-%A-%a
#SBATCH --job-name=Macs2
#SBATCH --partition=short
#SBATCH --array=0-7

# Handling errors
#set -x # debug mode on
set -o errexit # ensure script will stop in case of ignored error
set -o nounset # force variable initialisation
#set -o verbose
#set -euo pipefail

IFS=$'\n\t'

#set depositories
echo "Set up an array with all bowtie2-aligned sequence files ..." >&2


cult_0h=($(find "$HOME"/results/atacseq/picard -type f -name "*0h_R*__cleaned_mapped_sorted_q2_nodup.bam"))
cult_24h=($(find "$HOME"/results/atacseq/picard -type f -name "*24h_R*__cleaned_mapped_sorted_q2_nodup.bam"))



printf '%s\n' "${cult_0h[@]}" >&2
printf '%s\n' "${cult_24h[@]}" >&2



#Set up the temporary directory
SCRATCHDIR=/storage/scratch/"$USER"/"$SLURM_JOB_ID"

OUTPUT="$HOME"/results/atacseq/Macs2
mkdir -p "$OUTPUT"
mkdir -p -m 700 "$SCRATCHDIR"
cd "$SCRATCHDIR"

#Set up results sub-directories
mkdir -p "$SCRATCHDIR/cult_0h_R1"
mkdir -p "$SCRATCHDIR/cult_0h_R2"
mkdir -p "$SCRATCHDIR/cult_0h_R3"
mkdir -p "$SCRATCHDIR/cult_24h_R1"
mkdir -p "$SCRATCHDIR/cult_24h_R2"
mkdir -p "$SCRATCHDIR/cult_24h_R3"

trait_cult_0h=($(find "$SCRATCHDIR" -type d  -name "cult_0h*"))
trait_cult_24h=($(find "$SCRATCHDIR" -type d  -name "cult_24h*"))

SHORTNAME1=$(basename "${trait_cult_0h[$SLURM_ARRAY_TASK_ID]}")
SHORTNAME2=$(basename "${trait_cult_24h[$SLURM_ARRAY_TASK_ID]}")

echo "trait_cult_0h = " >&2
printf '%s\n' "${trait_cult_0h[@]}" >&2
echo "trait_cult_24h = " >&2
printf '%s\n' "${trait_cult_24h[@]}" >&2

#Load module

module purge
module load gcc/4.8.4 python python/2.7.9 numpy/1.9.2 cython/0.25.2 MACS2/2.1.2

#Run program
echo 'Peak calling ...'
macs2 callpeak -t "${cult_24h[$SLURM_ARRAY_TASK_ID]}" -c "${cult_0h[$SLURM_ARRAY_TASK_ID]}" -f BAM -B -g 'mm' -n "$SCRATCHDIR"/"$SHORTNAME1"

#Move results in one's directory
mv  "$SCRATCHDIR" "$OUTPUT"



echo "Stop job : "`date` >&2
