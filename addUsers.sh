#!/bin/bash

. vars.sh
USERS=users.txt

#expect dn as first field
awk -vRS= -vFS="\n"  '{
split($1,row,":");
sub(/^[ ]{1,}/, "", row[2]);
sub(/[ ]{1,}$/, "", row[2]);
dn=row[2];
json="[";
for(i=2; i<=NF; i++){
    split($i,row,":");
    sub(/^[ ]{1,}/, "", row[2]);
    sub(/[ ]{1,}$/, "", row[2]);
    values = "\"values\" : [";
    if(row[1] == "email"){
        values = values "{\"value\": \"" row[2] "\"";
        values = values ", \"confirmationData\": \"{\\\"confirmed\\\":false,\\\"confirmationDate\\\":0,\\\"sentRequestAmount\\\":0}\"}";
    }else{
        values = values "\"" row[2] "\"";
    }
    values = values "]";
    name = "\"name\": \"" row[1] "\"";
    groupPath = "\"groupPath\": \"/\"";
    visibility = "\"visibility\": \"full\"";
    attribute = "{" values "," name "," groupPath "," visibility "}";
    json = json attribute;
    if(i<NF){
        json = json ",";
    }
}
json = json "]";
print dn "\t" json;
}' $USERS  |
while read -r line; do
    DN=$(echo -e "$line" | sed -e 's/^\([^\t]*\)\t.*/\1/')
    JSON=$(echo -e "$line" | sed -e 's/^\([^\t]*\)\t\(.*\)/\2/')
    ENTITYID=$($CURLCMD -X POST "$BASEURL/entity/identity/x500Name/$DN?credentialRequirement=Password%20requirement" | sed -e 's/[^0-9]*\([0-9]\+\)[^0-9]*/\1/');
    $CURLCMD -X PUT -H"Content-Type: application/json" -d"$JSON" "$BASEURL/entity/$ENTITYID/attributes"
done;
