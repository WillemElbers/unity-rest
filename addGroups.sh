#!/bin/bash
set -o nounset

. vars.sh
count=0
GROUPSLIST=$1

#seems dn's are not compatible with groups and descriptions can't be added via rest
awk -vRS= -vFS="\n"  '{
cn="";
for(i=1; i<=NF; i++){
    split($i,row,":");
    sub(/^[ ]{1,}/, "", row[2]);
    sub(/[ ]{1,}$/, "", row[2]);
    if(row[1] == "cn"){
        cn = row[2];
        continue;
    }
    if(row[1] == "member"){
        split(row[2], parts, ",");
        for(j in parts){
            if(parts[j] ~ /mail/){
                split(parts[j], r, "=");
                mail = r[2];
                print mail > cn "_people.txt"
            }
        }
    }
}
}' $GROUPSLIST
for i in *_people.txt; do
    CN=${i%_people.txt};
    #create group
    $CURLCMD -X POST "$BASEURL/group/$CN"
    while read -r line; do
        (
            #echo $line
            #resolve entity name to id
            ENTITYID=$($CURLCMD "$BASEURL/resolve/email/$line" | sed -e 's/.*"id":\([0-9]\+\).*/\1/')
            if [[ "$ENTITYID" =~ ^[0-9]*$ ]]; then
                #add member to group
                $CURLCMD -fail -X POST "$BASEURL/group/$CN/entity/$ENTITYID" >/dev/null || echo "Failed to add user \"$ENTITYID\" to group \"$CN\"" >> error.log
            else
                echo "Failed to find user \"$line\" the parsed response was \"$ENTITYID\"" >> error.log
            fi;
        ) &
        let count+=1
        [[ $((count%CPUS)) -eq 0 ]]  && wait
    done < "$i"
done;

rm *_people.txt
