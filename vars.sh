#!/bin/bash

BASEURL=https://localhost:2443/rest-admin/v1
CURLCMD="curl --insecure -s -u admin:password"

CPUS=$(grep processor /proc/cpuinfo  | wc -l)
