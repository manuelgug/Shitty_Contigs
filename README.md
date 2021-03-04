# Shitty_Contigs

Shitty_Contigs.sh is a bash script which finds contigs in genomic assemblies that MAY BE the result of contaminants that were unintentionally sequenced with the intended sample. (Apparently, it also finds assembled plasmids and phages!). 


## Workflow of Shitty_Contigs.sh

1) Identify to what organism (at the genus level) your assembly belongs to, through analyzing a given quantity of blast hits for each contig. By summming all the hits for every unique genus found, Shitty_Contigs.sh determines the genus of your assembly as the most found genus.
2) List the contigs that contain at least one hit for the most found genus and labels them as "clean" contigs, and the contigs that does not and labels them as "possible contaminants".
3) Separate the "possible contaminants" from the "clean" the assembly.

IMPORTANT: You need to use your criterion and knowledge of your isolate to judge if contigs proposed as contaminants are to be considered as so. Some cases are more obvious, such as finding many contigs of *Klebsiella oxytoca* on an assembly from a hot spring isolate. However, phages and plasmids can be found in many phylogenetically distant organisms and many other sequences can be horizontally transferred. Also, sometimes there are no hits for some contigs. Shitty_Contigs.sh can only tell what contigs undoubtedly belong to an assembly. In the end, you decide what contigs are indeed shitty.

## Inputs

For the correct usage of Shitty_Contigs.sh, you need:
1) A genomic assembly with a .fasta extension on its file name (e.g. *Streptomyces_contam-Pseudomonas.fasta*)
2) A blast results file of the contigs against a reference database[*] with the same name as the assembly file plus a .blast extension (e.g. *Streptomyces_contam-Pseudomonas.fasta.blast*).

   >The output format of the blast file should be 0 (-outfmt 0) and it should not have any alignment (-num_alignments 0). 
   
   >The number of hits for each search (-num_descriptions) is important, as some sequences can be found in many organisms and yours won't necessarily appear as the best hit in some cases. That means that the less desciptions used, the more astringency applied which translates into a higher chance of getting false negatives (more possible contaminants). After testing the program with many descriptions (1, 5, 10, 15, 20) I found 20 to be a good number (-num_descriptions 20). However, feel free to modify as needed.

\[*]Shitty_Contigs.sh has been tested with the nt database from ncbi https://ftp.ncbi.nlm.nih.gov/blast/db/FASTA/nt.gz. You can download it and set it up with:

    wget https://ftp.ncbi.nlm.nih.gov/blast/db/FASTA/nt.gz 
    gunzip -d nt.gz #beware it is 386 GB   
    makeblastdb -in nt -dbtype nucl -parse_seqids #adds about 100 GB more

Sample command for the blast search (works for a single or many assemblies in the same folder):

    for f in *.fasta; do blastn -query $f -db nt -outfmt 0 -out "$f".blast -num_alignments 0 -num_threads 40 -num_descriptions 20; done

## Usage
Just place the correctly named assemblies and blast files on the same folder and run the script (you may need to make the script executable first with 

    chmod +x Shitty_Contigs.sh #only for the first time you run the script in a given computer
    ./Shitty_Contigs.sh

## Outputs

1) __*.poss-contam__ file: contains the contigs that didn't got a hit for the most found genera. If this file is not found on the results folder, all contigs belong to the same organism, therefore the assembly was already undoubtedly clean.
2) __*.CLEAN__ file: contains contigs that got at least one hit for the most found genera.
3) __*-poss_contam_blastresults__ file: contains the blast hits for the contigs in *.poss-contam. Use it for assessing if this contigs should or should not be removed fom the assembly.
