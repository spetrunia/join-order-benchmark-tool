#!/bin/bash

file1="${1}"
file2="${2}"
output_file="Regression_file.txt"
> "$output_file"
if [[ ! -f "$file1" || ! -f "$file2" ]] ; then
	echo "Usage : $0 file1 file2"
	echo " Both file must exists"
	exit 1
fi


paste  <(awk '{print $1 ,$4}' "$file1") <(awk '{print $4}' "$file2")| while read -r queryno val1 val2 ; do
if [[ -n "$val1" && -n "$val2" ]] ; then
	diff=$(( $val2 - $val1 ))
        if (($diff > 0 )) ; then
        echo "$queryno : $val1-> $val2 (Difference : $diff)" >> "$output_file"
	fi
        echo "$queryno : $val1-> $val2 (Difference : $diff)"
fi
done

echo "#################################"
echo "Queries taking more time in $file2"
echo "#################################"

cat $output_file
