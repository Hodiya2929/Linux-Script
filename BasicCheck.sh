#!/bin/bash

# saving user arguments
dir_path=$1;
prog_name=$2;
argu1=$3;
argu2=$4;

# variables for determing passing or failing
compile="FAIL";
leak="FAIL";
thread="FAIL";

# keeping the current path
path= $pwd;

# assign and print tests status
function print_status (){
	cd $path;
	compile=$1;
	leak=$2;
	thread=$3;
	printf "Compilation        Memory leaks        Thread race\n$compile               $leak                 $thread\n";
}

# moving to user path
	cd $dir_path;

# If makefile exist run it
if [ $(find ./ -iname "makefile" | wc -l) -gt 0 ]; then

# case the program already exist and makefile fails
if [ -e $prog_name ] ; then
	rm "$prog_name" ;
fi
# running make and not printing in terminal
        make > /dev/null 2>&1

# make status
        make_ret=$?;

# make status is 0 and program exist
if [ "$make_ret" -eq 0 ] && [ -e $prog_name ] ; then

# Run valgrind on background
	nohup valgrind --leak-check=yes --error-exitcode=1 ./$prog_name $argu1 $argu2 > /dev/null 2>&1
	valg_ret=$?
# Run helgrind on background
	nohup valgrind --tool=helgrind --error-exitcode=2 ./$prog_name $argu1 $argu2 > /dev/null 2>&1
	helg_ret=$?

# Cases to print
if [ $valg_ret == '0' ] && [ $helg_ret == '0' ] ; then
        print_status "PASS" "PASS" "PASS";
        exit 0;
elif [ "$valg_ret" -eq 0 ] && [ "$helg_ret" -eq 2 ] ; then
        print_status "PASS" "PASS" "FAIL";  
        exit 1;
elif [ "$valg_ret" -eq 1 ] && [ "$helg_ret" -eq 0 ] ; then
        print_status "PASS" "FAIL" "PASS";
        exit 2;
else
        print_status "PASS" "FAIL" "FAIL";
        exit 3;
fi

#make status is not 0 or prog doesnt exist
else
	print_status "FAIL" "FAIL" "FAIL" && exit 7;
fi

#there is no make file
else 
	print_status "FAIL" "FAIL" "FAIL" && exit 7;
fi

