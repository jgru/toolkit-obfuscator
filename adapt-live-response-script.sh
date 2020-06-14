#!/bin/bash

###########################################################################
# Display help page
###########################################################################
help()
{

    # Display Help
    echo
    echo '----------------------------------------------------------------'
    echo 'This script will replace all string occurences in a script by'
    echo 'the given changefile in .csv-format and print result to stdout'
    echo
    echo '----------------------------------------------------------------'
    echo
    echo 'Rename all commands inside live response script according to '
    echo 'the given change file in .csv-format, where the first colum  '
    echo 'specifies the original file name and the second colum the '
    echo 'the new file name '
    echo
    echo
    echo 'Example usage:'
    echo './adapt-live-response.script.sh --infile my-script.bat '
    echo '    --changefile changes.csv > my-modded-script.bat    '
    echo
    echo
}

############################################################################
# Main program
# Read change file, create temporary file, perform modifications and print
# result to stdout
############################################################################
while :
do
    case "$1" in
	-h | --help) # display Help
	    help
	    exit 0
	    ;;
	-c | --changefile)
	    changefile="$2"
	    shift 2
	    ;;

	-i | --infile)
	    infile="$2"
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

# Create temp file, which is a copy of the input
tmpfile="./$(basename ${infile}.tmp)"
cp ${infile} ${tmpfile}

while IFS= read -r line
do
    orig_cmd=$(echo ${line} | awk  -F',' '{print $1}')
    new_cmd=$(echo ${line} | awk  -F',' '{print $2}')

    # Change in situ
    sed -i "s/$orig_cmd/$new_cmd/g" ${tmpfile}

done < "${changefile}"

# Print result to stdout
cat ${tmpfile}

# Remove temporary file
rm ${tmpfile}
