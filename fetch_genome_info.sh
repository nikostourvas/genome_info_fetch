#!/bin/bash

# Input file with species (one species per line)
species_file="species_list_wo_subsp.txt"

# Output TSV file for the results
output_file="genome_info_table.tsv"

# Add headers to the output file (only once)
echo -e "Organism Name\tNumber of Chromosomes\tTotal Sequence Length" > $output_file

# Loop through each species in the species file
while IFS= read -r species
do
  echo "Processing: $species"

  # Generate a filename for the downloaded zip file
  zip_filename="${species// /_}.zip"

  # Download the genome metadata for the species using ncbi datasets
  datasets download genome taxon "$species" --reference --dehydrated --filename "$zip_filename"

  # Check if the download was successful
  if [ $? -eq 0 ]; then
    echo "Download successful for $species"

    # Extract relevant information using dataformat, but skip the header after the first species
    if [[ $(wc -l < "$output_file") -gt 1 ]]; then
      dataformat tsv genome --package "$zip_filename" --fields organism-name,assmstats-total-number-of-chromosomes,assmstats-total-sequence-len | tail -n +2 >> $output_file
    else
      dataformat tsv genome --package "$zip_filename" --fields organism-name,assmstats-total-number-of-chromosomes,assmstats-total-sequence-len >> $output_file
    fi

    # Optional: Clean up the zip file after extracting
    rm "$zip_filename"
  else
    echo "Failed to download data for $species"
  fi

done < "$species_file"

echo "Genome information extraction completed. Output saved to $output_file"
