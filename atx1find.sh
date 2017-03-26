#!/bin/sh

# Default for output format "6" (tabular): =====================================
# 'qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue
# bitscore'
#
# qseqid      = Query Seq ID
# sseqid      = Subject Seq ID
# pident      = % Identical matches
# length      = Alignment length
# mismatch    = Number of mismatches
# gapopen     = Number of gap openings
# qstart      = Start of alignment in Query
# qend        = End of alignment in Query
# sstart      = Start of alignment in Subject
# send        = End of alignment in Subject
# evalue      = Expect value
# bitscore    = Bit score
#
# Other values:
# qgi         = Query GI
# qacc        = Query accession
# sallseqid   = All subject Seq-ID(s), separated by a ';'
# sgi         = Subject GI
# sallgi      = All subject GI
# sacc        = Subject accession
# sallacc     = All subject accessions
# qseq        = Query sequence (aligned portion)
# sseq        = Subject sequence (aligned portion)
# score       = Raw score
# nident      = Number of identical matches
# positive    = Number of positive-scoring matches
# gaps        = Total number of gaps
# ppos        = Percentage of positive-scoreing matches
# frames      = Query and subject frames separated by a '/'
# qframe      = Query frame
# sframe      = Subject frame
# btop        = Blast traceback operations (BTOP)
# staxids     = Subject Taxonomy ID(s), separated by a ';' (in numerical order)
# sscinames   = unique Subject Scientific Name(s), sep'd by a ';'
# scomnames   = unique Subject Common Name(s), sep'd by a ';'
# sblastnames = unique Subject Blast Name(s), sep'd by a ';' (in ABC order)
# sskingdoms  = unique Subject Super Kingdom(s), sep'd by a ';' (in ABC order)
# stitle      = Subject Title
# sallstitles = All Subject Title(s), sep'd by a '<>'
# sstrand     = Subject Strand
# qcovs       = Query Coverage Per Subject (for all HSPs)
# qcovhsp     = Query Coverage Per HSP
# qcovus      : a measure of Query Coverage that counts a position in a subj
#               seq for this measure only once. The second time the position
#               is aligned to the query is not counted towards this measure.

# Method 1: Make blast DB from FASTA sequence and then blast it ================

makeblastdb -dbtype nucl -in /mnt/bigdata/processed_data/hittinger/fungal_genomes/to_vanderbilt/assemblies_y1000_all/yHAB127_kazachstania_bovina_160519.fas -out ./yHAB127_kazachstania_bovina_160519

# Long format output
tblastn -query ./ScerATX1.fas -db yHAB127_kazachstania_bovina_160519 -evalue 1.00e-20 -num_descriptions 2 -num_alignments 2 -outfmt 0

# Tabular output
echo '>Scer :: yHAB127_kazachstania_bovina_160519' > BlastOut.txt;
tblastn -query ./ScerATX1.fas -db yHAB127_kazachstania_bovina_160519 -evalue 1.00e-20 -num_alignments 2 -outfmt '6 sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore'

# XML output (more stable with Biopython)
tblastn -query ./ScerATX1.fas -db yHAB127_kazachstania_bovina_160519 -evalue 1.00e-20 -num_alignments 10 -outfmt 5

# Method 2: Blast FASTA sequence directly ======================================
# NOTE: Blasting the sequence directly can generate very long outputs if not using tabular output

# Tabular output
tblastn -query ./ScerATX1.fas -subject /mnt/bigdata/processed_data/hittinger/fungal_genomes/to_vanderbilt/assemblies_y1000_all/yHAB127_kazachstania_bovina_160519.fas -evalue 1.00e-20 -num_alignments 2 -outfmt '6 sseqid sgi sacc staxids sscinames scomnames sblastnames stitle'

# Iterating through files in assemblies folder to run some confidence
filename = $(basename "$fullfile")

for genome in /mnt/bigdata/processed_data/hittinger/fungal_genomes/to_vanderbilt/assemblies_y1000_all/*.fas; do
  fas=$( basename $genome .fas )
  makeblastdb -dbtype nucl -in /mnt/bigdata/processed_data/hittinger/fungal_genomes/to_vanderbilt/assemblies_y1000_all/${fas}.fas -out ./BlastDBs/${fas}
  tblastn -query ./ScerATX1.fas -db ${fas} -evalue 1.00e-20 -num_alignments 10 -outfmt 5 > ./BlastOut/${fas}.xml
done

for genome in /mnt/bigdata/processed_data/hittinger/fungal_genomes/to_vanderbilt/assemblies_y1000_all/*.fas; do
  fas=$( basename $genome .fas )
  tblastn -query ../ScerATX1.fas -db ../BlastDBs/${fas} -evalue 1.00e-10 -num_alignments 10 -outfmt 5 -out ./${fas}.xml
done

# Can move all Blast databases into another folder: the -i flag asks y/n if file exists already
# mv -i ./*.{nhr,nin,nsq} ./BlastDBs/
