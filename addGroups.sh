#!/bin/bash

. vars.sh
GROUPSLIST=groups.txt

#expect cn as first field, seems dn's are not compatible with groups and descriptions can't be added via rest
awk -vRS= -vFS="\n"  '{
split($1,row,":");
sub(/^[ ]{1,}/, "", row[2]);
sub(/[ ]{1,}$/, "", row[2]);
cn=row[2];
for(i=2; i<=NF; i++){
    split($i,row,":");
    sub(/^[ ]{1,}/, "", row[2]);
    sub(/[ ]{1,}$/, "", row[2]);
    if(row[1] == "member"){
        member_dn = row[2]
    }
    print member_dn > cn "_people.txt"
}
}' $GROUPSLIST
for i in *_people.txt; do
    CN=${i%_people.txt};
    #create group
    $CURLCMD -X POST "$BASEURL/group/$CN"
    while read -r line; do
        #resolve entity dn to id
        ENTITYID=$($CURLCMD "$BASEURL/resolve/x500Name/$line" | sed -e 's/.*"id":\([0-9]\+\).*/\1/')
        #add member to group
        $CURLCMD -X POST "$BASEURL/group/$CN/entity/$ENTITYID"
    done < "$i"
done;

rm *_people.txt
