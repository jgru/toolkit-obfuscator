#!/bin/bash


###########################################################################
# Display help page
###########################################################################
help()
{
    echo
    echo
    echo '----------------------------------------------------------------'
    echo '  _____              _  _     _  _                              '
    echo ' |_   _|            | || |   (_)| |                             '
    echo '   | |  ___    ___  | || | __ _ | |_                            '
    echo '   | | / _ \  / _ \ | || |/ /| || __|                           '
    echo '   | || (_) || (_) || ||   < | || |_                            '
    echo '  _\_/_\___/  \___/ |_||_|\_\|_| \__|        _                  '
    echo ' |  _  || |     / _|                        | |                 '
    echo ' | | | || |__  | |_  _   _  ___   ___  __ _ | |_  ___   _ __    '
    echo ' | | | ||  _ \ |  _|| | | |/ __| / __|/ _  || __|/ _ \ | __|    '
    echo ' \ \_/ /| |_) || |  | |_| |\__ \| (__| (_| || |_| (_) || |      '
    echo '  \___/ |_.__/ |_|   \__,_||___/ \___|\__ _| \__|\___/ |_|      '
    echo '                                                                '
    echo '================================================================'

    # Display Help
    echo
    echo 'Stay stealthy and obfuscate your IR toolkit'
    echo '----------------------------------------------------------------'
    echo
    echo 'This script will rename all executables inside a directory and'
    echo 'modify their hashes by appending a random byte'
    echo
    echo
    echo 'Example usage:'
    echo './obfuscate-toolkit.sh --rename prefix --append --num 3'
    echo ' --shorten 4 --dir ./toolkitdir'
    echo
    echo
}

process_file()
{
    f="$1"
    is_append="$2"
    is_random="$3"
    n=$4
    is_rename="$5"
    prefix="$6"
    s="$7"

    oh=$(shasum -a 256 $f | awk '{print $1}')

    if [ "${is_append}" == "true" ]
    then
	if [ "${is_random}" == "true" ]
	   then
	       dd if=/dev/random bs=1 count=$n status=none >> $f
	else
	    dd if=/dev/zero bs=1 count=$n status=none >> $f
	fi
    fi

    nh=$(shasum -a 256 $f | awk '{print $1}')

    if [ "${is_rename}" == "true" ]
    then
	if [ "${is_shorten}" == "true" ]
	then
	    nf=$(dirname $f)/$prefix-$(basename $f | awk -F'.' '{print $1}' | cut -c -"$s").exe
	else
	    nf=$(dirname $f)/$prefix-$(basename $f).exe
	fi
	mv $f $nf;
    else
	# Set new filename for printing csv to stdout
	nf="$f"
    fi


    echo $(basename $f),$(basename $nf),$oh,$nh
}


###########################################################################
# Processes exe-files in given directory and prints stats as .csv
#
# Params:
# $1 = directory path - string
# $2 = boolean specifying, whether to descend in subdirs recursively
# $3 = boolean specifying, whether to append bytes
# $4 = number of bytes to append
# $5 = boolean specifying, whether to append prefix to filename
# $6 = prefix to prepend
# $7 = number of letters of orig filename
###########################################################################
process ()
{
    dir="$1"
    is_norecursion="$2"
    is_append="$3"
    is_random="$4"
    n="$5"
    is_rename="$6"
    prefix="$7"
    s="$8"

    echo orig. filename,new filename,old SHA-256,new SHA-256

    if [[ "${is_norecursion}" == "true" ]]
    then  # process files in directory itself
	 find $dir -maxdepth 1 -type f -print0 |
	    while IFS= read -rd '' f;
	    do
		if [[ "${f}" == *.exe ]]
		then
		    process_file $f $is_append $is_random $n $is_rename $prefix $s
		fi
	done
    else  # Descend in subdirectories recursively
	    find ${dir} -type f -print0 |
	    while IFS= read -rd '' f;
	    do
		if [[ "${f}" == *.exe ]]
		then
		    process_file $f $is_append $is_random $n $is_rename $prefix $s
		fi
	done
    fi
}


############################################################################
# Main program
# Process the input options.
############################################################################
while :
do
    case "$1" in
	-d | --dir)
	    dir="$2"
	    shift 2
	    ;;
	-h | --help) # display Help
	    help
	    exit 0
	    ;;
	-a | --append-bytes)
	    is_append=true
	    n=$2
	    shift 2
	    ;;
	-n | --no-recursion)
	    is_norecursion=true
	    shift
	    ;;
	-q | --random)
	    is_random=true
	    shift
	    ;;
	-r | --rename)
	    is_rename=true
	    prefix="$2"
	    shift 2
	    ;;
	-s | --shorten)
	    is_shorten=true
	    s="$2"
	    shift 2
	    ;;
	-*)
	  echo "Error: Unknown option: $1" >&2
	  exit 1
	  ;;
	*)
	  break
	  ;;
       esac
done


if ! [[ "${is_shorten}" == "true" ]]
then
    s=100
fi

if ! [[ "${is_random}" == "true" ]]
then
    is_random=false
fi

if ! [[ "${is_rename}" == "true" ]]
then
    is_rename=false
    prefix=""
fi

#echo     $dir
#echo     $is_norecursion
#echo     $is_append
#echo     $is_random
#echo     $n
#echo     $is_rename
#echo     $prefix
#echo     $s

# Call processing function
if [[ "${is_rename}" == "true" || "${is_append}" == "true" ]]
then
    process $dir $is_norecursion $is_append $is_random $n $is_rename $prefix $s
fi
