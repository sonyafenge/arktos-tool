#!/bin/bash

# This script converting json to csv file

echo "converting json to csv file"

mkdir csv

convertednum=0
filenum=0
for name in $( ls | grep json);do
  filenum=$((filenum+1))
  case "$name" in
      APIResponsiveness*)
        echo "converting ${name} to csv"
        cat ${name} | jq -r -c ' ["Item", "Count", "unit", "Perc50", "Perc90", "Perc99"], (.dataItems[] | [(.labels.Scope+"_"+.labels.Resource+"_"+.labels.Verb), (.labels.Count), (.unit), (.data.Perc50), (.data.Perc90), (.data.Perc99)]) | @csv' > ./csv/${name%.*}.csv
        convertednum=$((convertednum+1))
        ;;
      MetricsForE2E*)
        ;;
      PodStartupLatency_PodStartupLatency*)
        echo "converting ${name} to csv"
        cat ${name} | jq -r -c ' ["Item", "unit", "Perc50", "Perc90", "Perc99"], (.dataItems[] | [(.labels.Metric), (.unit), (.data.Perc50), (.data.Perc90), (.data.Perc99)]) | @csv' > ./csv/${name%.*}.csv
	        convertednum=$((convertednum+1))
        ;;
      PodStartupLatency_SaturationPodStartupLatency*)
        echo "converting ${name} to csv"
        cat ${name} | jq -r -c ' ["Item", "unit", "Perc50", "Perc90", "Perc99"], (.dataItems[] | [(.labels.Metric), (.unit), (.data.Perc50), (.data.Perc90), (.data.Perc99)]) | @csv' > ./csv/${name%.*}.csv
        convertednum=$((convertednum+1))
        ;;
      ResourceUsageSummary*)
        echo "converting ${name} to csv"
        cat ${name} | jq -r -c ' ["Name", "Cpu", "Mem"], (."99"[] | [(.Name), (.Cpu), (.Mem)]) | @csv' > ./csv/99_${name%.*}.csv
        convertednum=$((convertednum+1))
        ;;
      SchedulingThroughput*)
        ;;
      SystemPodMetrics*)
        ;;
      *)
        ;;
  esac
done
echo "total ${filenum} json files, ${convertednum} converted to csv!"
