#!/bin/bash

. vars.sh
#todo could be more configurable

#echo -e $TEMPLATE;

for attr in dn cn sn displayName email friendlyCountryName postalAddress roomNumber telephoneNumber description eduPersonPrincipalName labeledURI; do
    ATTR_JSON='{ "flags": 0, "maxElements": 1, "minElements": 1, "selfModificable": false, "uniqueValues": false, "visibility": "full", "syntaxState": "{\"regexp\":\"\",\"minLength\":0,\"maxLength\":2147483647}", "displayedName": { "DefaultValue": "'"$attr"'", "Map": { "en": "'"$attr"'" } }, "i18nDescription": { "DefaultValue": null, "Map": {} }, "metadata": {}, "name": "'"$attr"'", "syntaxId": "string" }' 

    $CURLCMD -X POST -H"Content-type: application/json" -d "$ATTR_JSON" $BASEURL/attributeType
done

#need bigger images, seems to be present in default installation but 120x120 is small
JPEG_PHOTO='{ "flags": 0, "maxElements": 1, "minElements": 1, "selfModificable": false, "uniqueValues": false, "visibility": "full", "syntaxState": "{\"maxWidth\":200,\"maxHeight\":200,\"maxSize\":2000000}", "displayedName": { "DefaultValue": "jpegPhoto", "Map": { "pl": "Zdjęcie", "en": "Small photo" } }, "i18nDescription": { "DefaultValue": null, "Map": { "pl": "Małe zdjęcie w formacie JPEG", "en": "Small JPEG photo for users profile" } }, "metadata": {}, "name": "jpegPhoto", "syntaxId": "jpegImage" }'  
$CURLCMD -X PUT -H"Content-type: application/json" -d "$JPEG_PHOTO" $BASEURL/attributeType

#o seems to have simmilar issue length 33, longest seen in data ~180
ORG='{ "flags": 0, "maxElements": 10, "minElements": 1, "selfModificable": false, "uniqueValues": false, "visibility": "full", "syntaxState": "{\"regexp\":\"\",\"minLength\":2,\"maxLength\":256}", "displayedName": { "DefaultValue": "o", "Map": { "pl": "Organizacja", "en": "Organization" } }, "i18nDescription": { "DefaultValue": null, "Map": {} }, "metadata": {}, "name": "o", "syntaxId": "string" }'  
$CURLCMD -X PUT -H"Content-type: application/json" -d "$ORG" $BASEURL/attributeType
