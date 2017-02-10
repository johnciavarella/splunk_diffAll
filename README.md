# Purpose
This is a tool for comparing conf and app files amongst similar/dissimilar systems in Splunk. 

# Tested Version
Splunk Entperise 6.5.x

# Files Ingest
It can untar or use regular flat directory sturctures 

# Useage
To use script please use the following

## Comparing different hosts
./linuxDiff.sh host <host1> <host2>

## Comparing Apps 

./linuxDiff.sh app <app1> <app2>

example ./linuxDiff.sh app server1/system/local/ server2/system/local

## Cleaning up files
./linuxDiff.sh cleanup

## Review files generated
./linuxDiff.sh review <app|host> 

Will display diffs in in full color for the latest pull of each repsective App or Host compare
