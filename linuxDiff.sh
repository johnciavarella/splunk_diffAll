#!/bin/bash

Type=$1
Host1=$2
Host2=$3
directoryArray=("system/local" "apps" "deployment-apps" "master-apps" "disabled-apps")
date=`date +%s`

help(){
echo -e "To use script please use the following\nhost <host1> <host2>\n\ndefault <defaultapp> <currentappdefault>\n\ncleanup:Used to clean up archived files\n\nreview: used to review the latest compare.file in full color"
}

filechecker(){
if [[ $Host1 == *".tar" ]]; then
	echo -e "$Host1 is a tar. Extracting"
	unpacker1
	folderName=`echo $Host1| sed -E 's/(.+).tar/\1/'`
	Host1="$folderName/etc/"
	echo -e "New Host1: $Host1"
fi
if [[ $Host2 == *".tar" ]]; then
        echo -e "$Host2 is a tar. Extracting"
	unpacker2
        folderName=`echo $Host2| sed -E 's/(.+).tar/\1/'`
        Host2="$folderName/etc/"
        echo -e "New Host2: $Host2"
fi
sleep 5;
echo $Host1 $Host2
if [[ $Host1 == *"etc/" ]] && [[ $Host2 == *"etc/" ]]; then
        echo "Files look good. Starting Host Check"
else
        echo -e "One directory was not an /etc directory\n\nHost1: $Host1\nHost2: $Host2"
	exit
fi
}

unpacker1(){
folderName=`echo $Host1| sed -E 's/(.+).tar/\1/'`
echo "Unpacking $Host1 to foldername $folderName"
mkdir -p $folderName/etc && tar xf $Host1 -C $folderName/etc --strip-components 1
}

unpacker2(){
folderName=`echo $Host2| sed -E 's/(.+).tar/\1/'`
echo "Unpacking $Host2 to foldername $folderName"
mkdir -p $folderName/etc && tar xf $Host2 -C $folderName/etc --strip-components 1
}

hostCompare(){
	if [ -f "compare.file" ]; then
		mv compare.file "archive.compare.$date"
	fi

	for loadArray in ${directoryArray[*]}; do
		arrayHost1=$Host1$loadArray 
		arrayHost2=$Host2$loadArray
		if [ -d "$Host1$loadArray" ];then
		        if [ -d "$Host2$loadArray" ];then
				echo -e "\n\n######################\nNow Checking: $loadArray\n\n" >> compare.file 
				#echo "Etc System Local Directory Compare $loadArray" >> compare.file 
				diff $arrayHost1 $arrayHost2 | grep Only >> compare.file 
				echo -e "\n\n" >> compare.file
			fi
		fi
	done


	for loadArray in ${directoryArray[*]}; do
        	arrayHost1=$Host1$loadArray
        	arrayHost2=$Host2$loadArray
	        if [ -d "$Host1$loadArray" ];then
                	if [ -d "$Host2$loadArray" ];then
                                echo -e "\n\n $loadArray\n\n" >> compare.file
                        	echo "Deep Dive Compare $loadArray" >> compare.file
	                        diff -cr $arrayHost1 $arrayHost2 | grep -v Only >> compare.file 
        	                echo -e "\n\n" >> compare.file
                	fi
	        fi
	done
}

appCompare(){
	echo "loaded app compare 1111"
	app=$Host1
	app2=$Host2
	echo $app $app2
        if [ -f "app.compare.file" ]; then
                mv app.compare.file "app.archive.compare.$date"
        fi
		echo -e "\n\n######################\nNow Checking: $app\n\n" >> app.compare.file
                #echo "Etc System Local Directory Compare $loadArray" >> app.compare.file
                diff $app $app2 | grep Only >> app.compare.file
                echo -e "\n\n" >> app.compare.file
                        
       
		echo -e "\n\n######################\nNow Checking: $app\n\n" >> app.compare.file
                #echo "Etc System Local Directory Compare $loadArray" >> app.compare.file
                diff -cr $app $app2  >> app.compare.file
                echo -e "\n\n" >> app.compare.file       


}

#
######## Main ########
# Turn on for variable debug
#echo -e "1:$1\n2:$2\n3:$3\nloadarray:$loadArray\nHost:$Host1\nHost2:$Host2\n"


if [ -z $1 ]; then
	help
elif [ $Type = "host" ]; then
	echo "Host Compare"
	filechecker
	hostCompare	
elif [ $Type = "defaults" ]; then
	echo "Defaults"
elif [ $Type = "review" ]; then
	if [ $2 = "host" ]; then
		cat compare.file | colordiff  | less -R
	elif [ $2 = "app" ]; then
	        cat app.compare.file | colordiff  | less -R
	fi
elif [ $Type = "app" ]; then
        echo "App Compare"
        appCompare
elif [ $Type = "cleanup" ]; then 
	if ls *.file 1> /dev/null 2>&1; then
		rm *.file
	else
		echo "Nothing to cleanup"
	fi
else
	help
fi
