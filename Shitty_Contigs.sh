#!/bin/bash

echo""
echo""

echo "  ██████  ██░ ██  ██▓▄▄▄█████▓▄▄▄█████▓▓██   ██▓    ▄████▄   ▒█████   ███▄    █ ▄▄▄█████▓ ██▓  ▄████   ██████ 
▒██    ▒ ▓██░ ██▒▓██▒▓  ██▒ ▓▒▓  ██▒ ▓▒ ▒██  ██▒   ▒██▀ ▀█  ▒██▒  ██▒ ██ ▀█   █ ▓  ██▒ ▓▒▓██▒ ██▒ ▀█▒▒██    ▒ 
░ ▓██▄   ▒██▀▀██░▒██▒▒ ▓██░ ▒░▒ ▓██░ ▒░  ▒██ ██░   ▒▓█    ▄ ▒██░  ██▒▓██  ▀█ ██▒▒ ▓██░ ▒░▒██▒▒██░▄▄▄░░ ▓██▄   
  ▒   ██▒░▓█ ░██ ░██░░ ▓██▓ ░ ░ ▓██▓ ░   ░ ▐██▓░   ▒▓▓▄ ▄██▒▒██   ██░▓██▒  ▐▌██▒░ ▓██▓ ░ ░██░░▓█  ██▓  ▒   ██▒
▒██████▒▒░▓█▒░██▓░██░  ▒██▒ ░   ▒██▒ ░   ░ ██▒▓░   ▒ ▓███▀ ░░ ████▓▒░▒██░   ▓██░  ▒██▒ ░ ░██░░▒▓███▀▒▒██████▒▒
▒ ▒▓▒ ▒ ░ ▒ ░░▒░▒░▓    ▒ ░░     ▒ ░░      ██▒▒▒    ░ ░▒ ▒  ░░ ▒░▒░▒░ ░ ▒░   ▒ ▒   ▒ ░░   ░▓   ░▒   ▒ ▒ ▒▓▒ ▒ ░
░ ░▒  ░ ░ ▒ ░▒░ ░ ▒ ░    ░        ░     ▓██ ░▒░      ░  ▒     ░ ▒ ▒░ ░ ░░   ░ ▒░    ░     ▒ ░  ░   ░ ░ ░▒  ░ ░
░  ░  ░   ░  ░░ ░ ▒ ░  ░        ░       ▒ ▒ ░░     ░        ░ ░ ░ ▒     ░   ░ ░   ░       ▒ ░░ ░   ░ ░  ░  ░  
      ░   ░  ░  ░ ░                     ░ ░        ░ ░          ░ ░           ░           ░        ░       ░  
                                        ░ ░        ░                                                          "
echo "                                                                                                   Version 1.0"
echo "                                                                                     by Manuel II García-Ulloa"
echo "                                                                                          github.com/manuelgug"
echo""
echo""
echo""

#Leave only the genus of each hit for every contig
for f in *.blast; do awk '/^Query=/,/^Lambda/' $f | sed '/^Query= / {N ; s/\n//g}' | sed '/^$/d' | sed -r '/Length|Score|Lambda|Sequences producing significant alignments:/d' > "$f".formatted; done
for f in *.formatted; do sed 's/Query= /Query=/g' $f | sed 's/[^\s]*\s\s//' | sed 's/\s.*//' | sed '/^$/d' | sed 's/^[0-9].*//g'> $f.limpio; done

#Split formatted blast results by contig
sed -i 's/Query=/--\nQuery=/g' *.limpio
sed -i '1d' *.limpio
for f in *.limpio; do csplit $f -s -f hit_$f /--/ {*}; done
sed -i 's/--//g' hit*
sed -i '/^$/d' hit*

#List names of "contaminant" and "clean" contigs in two separete files
echo "LISTING CONTIGS"
echo ""
for f in *.limpio 
do
	MOST_FREQUENT=$(cat $f | tr -s " " "\n" | sort | uniq -c | sort | sed '/Query=/d' | tail -n1 | sed 's/[0-9]*//g' | sed 's/ //g')
	for j in hit_$f*
	do
                if grep -q $MOST_FREQUENT $j
                then
                        head -1 $j >> SIN_CONTAMINANTES_$f.txt
                else
                        head -1 $j >> CON_CONTAMINANTES_$f.txt
                fi
        done
	echo "Most contigs of ${f%%.formatted.limpio} belong to $MOST_FREQUENT" "... contigs listed"
done

sed -i 's/Query=/>/g' *CONTAMINANT*
rm hit*.formatted.limpio*

echo ""
echo ""

#Split contigs in separate files
for x in *.fasta; do csplit $x -s -f $x-contig /\>/ {*}; done

#Use previously listed names of contigs as index to group "contaminant" and "clean" contigs
echo "SEPARATING CONTIGS"
echo ""
for f in *.fasta 
do
	for j in $f-contig* 
	do
		if grep -q "$(head -1 $j)" CON_CONTAMINANTES_$f* "$(head -1 $j)" 2>/dev/null
		then 
			cat $j >> $f.poss_contam
		else
			cat $j >> $f.CLEAN
		fi
	done 
	echo $f "... assembly cleaned"
done

#List blast hits of "contaminant" contigs
for f in *.blast; do
        awk '
        BEGIN   { in_block=0 }
        NR==FNR { array[substr($0, 2)]=1; next }
         in_block == 0 {
         for (item in array) {
         if ($0 ~ item) {
         in_block=1
         print($0)
         next
             }
            }
          }
        in_block == 1 { print }
        in_block == 1 && /^Lambda/ { in_block=0 }
        '  CON*$f*.txt $f >> $f-poss_contam_blastresults 2>/dev/null
done

#Group results of each assembly in a separate folder
rm *contig* *formatted *.limpio *CONTAMINANTES*
for x in *.fasta; do mkdir "${x%%.fasta}"_results; done	
for x in *.fasta; do mv *"${x%%.fasta}"* "${x%%.fasta}"_results/ 2>/dev/null; done

echo ""
echo ""
echo "DONE!"
echo ""
