#!/bin/bash

file1="${1}"
file2="${2}"
output_file="Relative_speed.txt"
> "$output_file"
if [[ ! -f "$file1" || ! -f "$file2" ]] ; then
	echo "Usage : $0 file1 file2"
	echo " Both file must exists"
	exit 1
fi

echo "query name : relative speed(time_in_$file2 / time_in_$file1)" >> "$output_file"
paste  <(awk '{print $1 ,$4}' "$file1") <(awk '{print $4}' "$file2")| while read -r queryno val1 val2 ; do
if [[ -n "$val1" && -n "$val2" ]] ; then
	if [ $val1 == 0 ]; then
		val1=0.5
	fi
	diff=$( echo  "scale=2; $val2 / $val1" | bc)
        echo "$queryno : $diff" >> "$output_file"
fi
done

echo "#################################"
echo "Queries taking more time in $file2"
echo "#################################"

cat $output_file
