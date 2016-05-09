#!/bin/bash

. vars.sh
#todo could be more configurable

#echo -e $TEMPLATE;

for attr in cn sn displayName email friendlyCountryName o postalAddress roomNumber telephoneNumber description eduPersonPrincipalName labeledURI; do
    ATTR_JSON='{ "flags": 0, "maxElements": 1, "minElements": 1, "selfModificable": false, "uniqueValues": false, "visibility": "full", "syntaxState": "{\"regexp\":\"\",\"minLength\":0,\"maxLength\":2147483647}", "displayedName": { "DefaultValue": "'"$attr"'", "Map": { "en": "'"$attr"'" } }, "i18nDescription": { "DefaultValue": null, "Map": {} }, "metadata": {}, "name": "'"$attr"'", "syntaxId": "string" }' 

    $CURLCMD -X POST -H"Content-type: application/json" -d "$ATTR_JSON" $BASEURL/attributeType
done
