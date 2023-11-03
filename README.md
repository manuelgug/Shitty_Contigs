# Shitty Contigs

![alt text](https://github.com/manuelgug/Shitty_Contigs/blob/main/images/Shitty_Contigs_logo.png)

Shitty_Contigs.sh is a bash script for finding contigs/scaffolds in genomic assemblies that MAY BE the result of contaminants unintentionally sequenced alongside an intended isolate. (Apparently, it also finds assembled plasmids and phages!). It works for any assembly from any organism.


## Workflow of Shitty Contigs

1) Identify to what organism (at the genus level) an assembly belongs to, through analyzing a given quantity of blast hits for each contig: by summming all the hits for every unique genus found, Shitty_Contigs.sh labels the genus with the most hits determines as the genus of the assembly.
2) List the contigs that contain at least one hit for the most found genus and labels them as "clean" contigs, and the contigs that does not and labels them as "possible contaminants".

![alt text](https://github.com/manuelgug/Shitty_Contigs/blob/main/images/listing.png) 

3) Separate the possible contaminants from the clean the assembly.

![alt text](https://github.com/manuelgug/Shitty_Contigs/blob/main/images/separating.png)

4) Generate figures with shitty_figures.R (Shitty_Contigs.sh takes care of it)

![alt text](https://github.com/manuelgug/Shitty_Contigs/blob/main/images/shitty_figures_results.png)
Figure 1. Blast hits for each found genus on each assembly. The green bar represents the most found genus and all the orange ones are other genera found fewer times. A expected, *Streptomyces* (__A__) and *Pseudomonas* (__B__) assemblies appear clean, and the *Streptomyces* assembly contaminated with 100 *Pseudomonas* contigs (__C__) appears indeed contaminated. Other genera than the most found one should have a really small quantity of hits, as in __A__ and __B__. Also, you can look for patterns on the genera found: in __A__ all hits are environmental Actinobacteria and in __B__ all genera are oportunistic pathogens of some sort. In both cases, the most found genus is related to the additional marginally found genera wich, considering their extremely low abundance, most likely means that the assembly is OK. It makes sense that phylogenetically or ecologically related organisms share some similar sequences. 

IMPORTANT: You need to use your own criterion and knowledge of your isolate to judge if contigs proposed as contaminants are to be considered as so. Some cases are obvious, such as finding many contigs of *Klebsiella oxytoca* on an assembly from a hot spring isolate or elephant contigs on an *Arabidopsis* assembly. However, in microorganisms, phages and plasmids can be found in many phylogenetically distant organisms and many other sequences can be horizontally transferred. Also, sometimes there are no hits for some contigs. Shitty_Contigs.sh can only tell what contigs undoubtedly belong to an assembly. In the end, you decide what contigs are indeed shitty.

## Inputs

For the correct usage of Shitty Contigs, you need:
1) A genomic assembly with a .fasta extension on its file name (e.g. *Streptomyces_contam-Pseudomonas.fasta*)
2) A blast results file of the contigs against a reference database[*] with the same name as the assembly file plus a .blast extension (e.g. *Streptomyces_contam-Pseudomonas.fasta.blast*).

   +The output format of the blast file should be 0 (-outfmt 0) and it should not have alignments (-num_alignments 0). 
   
   +The number of hits for each search (-num_descriptions) is important, as some sequences can be found in many organisms and yours won't necessarily appear as the best hit in some cases. It could be the 2nd, 3rd or 10th hit although still with a low e-value and high bitscore. That means that the less descriptions used, the more astringency applied, which translates into a higher chance of getting false negatives (more possible contaminants). After testing the program with many descriptions (1, 5, 10, 15, 20) I found 20 to be a good enough value (-num_descriptions 20). However, feel free to modify as needed.

\[*]Shitty Contigs has been tested with the nt database from ncbi https://ftp.ncbi.nlm.nih.gov/blast/db/FASTA/nt.gz. You can download it and set it up with:

    wget https://ftp.ncbi.nlm.nih.gov/blast/db/FASTA/nt.gz 
    gunzip -d nt.gz #beware it is 386 GB in size  
    makeblastdb -in nt -dbtype nucl -parse_seqids #adds about 100 GB more

Sample command for the blast search (works for a single or many assemblies in the same folder):

    for f in *.fasta; do blastn -query $f -db nt -outfmt 0 -out "$f".blast -num_alignments 0 -num_threads 40 -num_descriptions 20; done

## Usage
Just place the correctly named assemblies and blast files on the same folder (or copy the scripts to your PATH) and run the bash script 

    chmod +x Shitty_Contigs.sh shitty_figures.R #only for the first time you run the program in a given computer
    ./Shitty_Contigs.sh
****
### Example inputs

+Pseudomonas_aeruginosa_10-75.fasta & Pseudomonas_aeruginosa_10-75.fasta.blast: clean assembly (3933 contigs), all contigs belong to *Pseudomonas*  

+Streptomyces_albidoflavus_NRRL_WC-3066.fasta & Streptomyces_albidoflavus_NRRL_WC-3066.fasta.blast: clean assembly (287 contigs), all contigs belong to *Streptomyces*  

+Streptomyces_contam-Pseudomonas.fasta & Streptomyces_contam-Pseudomonas.fasta.blast: *Streptomyces* assembly contaminated with 100 *Pseudomonas* contigs

## Outputs

1) __*.poss-contam__ file: contains the contigs that didn't got a hit for the most found genera. If this file is not found on the results folder, all contigs belong to the same organism, therefore the assembly was already undoubtedly clean.
2) __*.CLEAN__ file: contains contigs that got at least one hit for the most found genera. 
3) __*-poss_contam_blastresults__ file: contains the blast hits for the contigs in *.poss-contam. Use it for assessing if this contigs should or should not be removed fom the assembly.
4) __*.table__ file: table of hits for every unique genus found in the assembly. This is the input for shitty_figures.R.

## Credits

Manuel II García-Ulloa  
manuel.gug@hotmail.com  
github.com/manuelgug  

Mariette Viladomat Jasso
marietteviladomat@gmail.com
https://github.com/MarietteViladomat
