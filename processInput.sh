#!/bin/bash
set -o nounset

INPUT=$1

#remove consecutive blanks and reformat ::
cat -s $INPUT | sed -e 's/::/:/' |
awk -vRS= -vFS="\n" '{
    for(i=1; i<=NF; i++){
        split($i,row,":");
        sub(/^[ ]{1,}/, "", row[2]);
        sub(/[ ]{1,}$/, "", row[2]);
        if(tolower(row[1]) ~ /objectclass/){
            if(row[2] ~ /Person/){
                print $0 "\n" > "users.txt";
                break;
            }else if(row[2] ~ /groupOfNames/){
                print $0 "\n" > "groups.txt";
                break;
            }
        }
    }
}'

rm -f error.log

echo "=== Adding attributes"
./addAttributes.sh

echo "=== Adding users"
./addUsers.sh <(grep -vi "objectclass" users.txt)

echo "=== Adding groups"
./addGroups.sh <(grep -vi "objectclass" groups.txt)

rm users.txt groups.txt
