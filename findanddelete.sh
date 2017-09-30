#!/bin/bash
if [ $# -eq 0 ]
then
	echo ""
    echo "$0: Error command arguments missing!"
    echo "Usage: findanddelete [directory] [filename]"
    exit 1
fi

directory=$1
file=$2 #file to delete

echo 
read -p "deleting  '$file' recursively in $directory, right?" -n 1 -r
echo    # (optional) move to a new line
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 1
fi
#find $directory -name u* -type d | while read line
#do 
#if [ -f $line/InstantValues ]
#	then 
#	badfolder=$( echo $line | sed 's;/InstantValues;;' )
#	echo $badfolder
#	rm -r $badfolder
#fi
#done
#echo "deleting done!"
find $directory -name $file -type f | while read line
do
	rm $line
done
echo "deleting done!"



#do thirdline=$( sed -n '3p' < $line )
#if [ "$thirdline" = "ModPot 1 (Bessel)" ]
#	then 
#	badfolder=$( echo $line | sed 's;/sim_Settings.txt;;' )
#	rm -r "$badfolder"
#fi
#done
#echo "deleting done!"
#touch test; fi; done



# find $directory -name sim_Settings.txt -type f | while read line
# do thirdline=$( sed -n '3p' < $line )
# if [ "$thirdline" == "ModPot 1 (Bessel)" ]
# 	then 
# 	badfolder=$( echo $line | sed 's;/sim_Settings.txt;;' )
# 	rm -r "$badfolder"
# fi
# done
# echo "deleting done!"