#!/bin/bash
a=`/usr/bin/supervisorctl status`;
if [[ $a == *"FATAL"* ]];
 then exit 1;
 else exit 0;
fi;
