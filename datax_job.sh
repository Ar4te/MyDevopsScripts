#!/bin/bash
big_tables_file="./big_tables"
bbig_tables_file="./bbig_tables"
little_tables_file="./little_tables"
medium_tables_file="./medium_tables"

for file in "$big_tables_file" "$bbig_tables_file" "$little_tables_file" "$medium_tables_file" ; do
    if [ ! -f "$file" ]; then
        touch "$file"
    fi
    
done


awk '{
    if ($3 <= 10000){
        print $2 > "'$little_tables_file'"
    } else if ($3 > 10000 && $3 <= 100000){
        print $2 > "'$medium_tables_file'"
    } else if ($3 > 100000 && $3 <= 1000000){
        print $2 > "'$big_tables_file'"
    } else {
        print $2 > "'$bbig_tables_file'"
    }
}' tst_order.log
