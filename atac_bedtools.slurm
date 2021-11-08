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
