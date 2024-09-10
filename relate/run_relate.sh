#!/bin/bash

# # # Generate a Genetic Map
# # # TODO: modify to get the actual recombination rate from the parameter.tsv file
# # # TODO: output to the output directory
# echo -e "position COMBINED_rate(cM/Mb)\n1 0.0000001619\n1000000 1.0" > genetic_map.txt


# # # # prepare the input .haps and .sample file

# # from ms file
# Rscript relate_v1.2.2_MacOSX_M/scripts/ms2haps.R ../output/simulations/jiza/1_genotypes.ms example_ms 1000000

# relate_v1.2.2_MacOSX_M/bin/Relate --mode All \
# 	--haps example_ms.haps \
# 	--sample example_ms.sample \
# 	--map genetic_map.txt \
# 	-N 100000 \
# 	-m 2.25e-8 \
# 	-o example \
# 	--seed 1


relate_v1.2.2_MacOSX_M/scripts/SampleBranchLengths/SampleBranchLengths.sh \
                 -i example \
                 -o example_sub \
                 -m 2.25e-8 \
                 --coal 0.00002 \
                 --format n \
                 --num_samples 5 \
                 --seed 1 
                #  --first_bp 10000 \
                #  --last_bp 20000 \
                