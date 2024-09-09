CONFIGFILES=$(ls resources/simulation-parameters/hard-sweeps-with-known-s/hard_s0.1.yaml)
NUM_SIMS=1

for file in ${CONFIGFILES}
do
	snakemake --use-conda --snakefile 02_simulate.smk --configfile ${file} --config slim=slim normalization_stats=resources/normalization-stats.tsv simulations=${NUM_SIMS} use_subdirectory=true -c1
done

# 3029617699