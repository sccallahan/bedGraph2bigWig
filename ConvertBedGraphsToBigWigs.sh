#!/usr/bin/env bash

###################################################################
## Author: Carson Callahan
## Purpose: Convert bedGraphs to bigWigs
## Date: 2019-08-09
## Notes: requires bedGraphToBigWig binary from UCSC - OS specific
###################################################################


#### Arguments ####

#### Code starts here ####

# Simplest way to do this is probably a for loop
COUNTER=1
num=$(ls *.bedGraph|echo `wc -l`|awk '{print $1}')
echo There are ${num} bedGraph files to convert
for file in *.bedGraph;
do
	echo Working on file ${COUNTER}... please wait
	## first we prepare the file for the UCSC binary
	# sort the file
	LC_COLLATE=C sort -k1,1 -k2,2n ${file} > ${file%.bedGraph}_sorted.bedGraph
	# re-add header
	sed -i '1 i\track\ttype=bedGraph' ${file%.bedGraph}_sorted.bedGraph
	# remove old header from bottom of file
	head -n -1 ${file%.bedGraph}_sorted.bedGraph > tmp.bedGraph ; mv tmp.bedGraph ${file%.bedGraph}_sorted.bedGraph
	# run UCSC binary conversion tool
	./bedGraphToBigWig ${file%.bedGraph}_sorted.bedGraph http://hgdownload.cse.ucsc.edu/goldenPath/hg19/bigZips/hg19.chrom.sizes ${file%.bedGraph}_sorted.bigWig
	echo Finished converting file number ${COUNTER} to bigWig
	let COUNTER=COUNTER+1
done
echo Finished converting all bedGraph files








