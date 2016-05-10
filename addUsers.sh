#!/bin/bash
set -o nounset

. vars.sh
count=0
USERS=$1

awk -vRS= -vFS="\n"  '{
json="[";
id="";
for(i=1; i<=NF; i++){
    split($i,row,":");
    sub(/^[ ]{1,}/, "", row[2]);
    sub(/[ ]{1,}$/, "", row[2]);
    values = "\"values\" : [";
    if(row[1] == "mail"){
        row[1] = "email";
        id = row[2];
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
print id "\t" json;
}' $USERS  |
while read -r line; do
    (
        ID=$(echo -e "$line" | sed -e 's/^\([^\t]*\)\t.*/\1/');
        #echo $ID
        JSON=$(echo -e "$line" | sed -e 's/^\([^\t]*\)\t\(.*\)/\2/');
        ENTITYID=$($CURLCMD -X POST "$BASEURL/entity/identity/email/$ID?credentialRequirement=Password%20requirement" | sed -e 's/[^0-9]*\([0-9]\+\)[^0-9]*/\1/');
        if [[ "$ENTITYID" =~ ^[0-9]*$ ]]; then
            $CURLCMD -fail -X PUT -H"Content-Type: application/json" -d"$JSON" "$BASEURL/entity/$ENTITYID/attributes" >/dev/null || echo "Failed to add attributes for user \"$ID\": \"$JSON\"" >> error.log;
        else
            echo "Failed to create user \"$ID\" the parsed response was \"$ENTITYID\"" >> error.log 
        fi;
    ) &
    let count+=1
    [[ $((count%CPUS)) -eq 0 ]]  && wait
done;
