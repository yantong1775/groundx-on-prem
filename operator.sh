#!/bin/bash

# valid_groups order is important:
# the groups are executed in order for deploy
# and reverse order for destroy
valid_groups=("init" "services" "app")
recursive_types=("init" "services" "app")

valid_apps=("groundx" "layout-webhook" "pre-process" "process" "queue" "summary-client" "upload" "ranker" "layout" "summary")
valid_init=("add" "config")
valid_services=("cache" "db" "file" "search" "stream")

# for helm release explicit clean up, in case terraform fails to clean up
golang_apps=("groundx" "layout-webhook" "pre-process" "process" "queue" "summary-client" "upload")
inference_apps=("ranker" "summary")
inference_process_apps=("layout")

GROUP=""
APP=""
INIT=""
SERVICE=""

if [[ "$1" =~ ^- ]]; then
  IN=""
else
  IN=$1
  shift

  if [[ " ${valid_groups[@]} " =~ " $IN " ]]; then
    GROUP=$IN
  elif [[ " ${valid_apps[@]} " =~ " $IN " ]]; then
    APP=$IN
  elif [[ " ${valid_init[@]} " =~ " $IN " ]]; then
    INIT=$IN
  elif [[ " ${valid_services[@]} " =~ " $IN " ]]; then
    SERVICE=$IN
  else
    echo "Unknown request type: $IN"
    exit 1
  fi
fi

CLEAR=0
TFLAG=0

while getopts ":ct" opt; do
  case $opt in
    c)
      CLEAR=1
      ;;
    t)
      TFLAG=1
      ;;
    \?)
      echo "Invalid option: -$OPTARG"
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument."
      exit 1
      ;;
  esac
done

deploy() {
  local dir="$1"

  if [[ -d "$dir" ]]; then
    echo "Deploying $dir"
    terraform -chdir="$dir" init
    terraform -chdir="$dir" plan
    if [[ "$TFLAG" -eq 1 ]]; then
      echo "Skipping terraform apply"
    else
      terraform -chdir="$dir" apply --auto-approve
    fi
  else
    echo "Error: Directory '$dir' does not exist."
    exit 1
  fi
}

destroy() {
  local dir="$1"

  if [[ -d "$dir" ]]; then
    echo "Destroying $dir"
    if [[ "$TFLAG" -eq 1 ]]; then
      terraform -chdir="$dir" destroy
    else
      terraform -chdir="$dir" destroy --auto-approve
      for app in "${inference_apps[@]}"; do
        if [[ "$dir" == */"$app" ]]; then
          helm delete -n eyelevel $app-api-cluster > /dev/null 2>&1
          helm delete -n eyelevel $app-inference-cluster > /dev/null 2>&1
          if [[ "$app" == "layout" ]]; then
            helm delete -n eyelevel $app-process > /dev/null 2>&1
          fi
          return 0
        fi
      done
      for app in "${inference_process_apps[@]}"; do
        if [[ "$dir" == */"$app" ]]; then
          helm delete -n eyelevel $app-api-cluster > /dev/null 2>&1
          helm delete -n eyelevel $app-inference-cluster > /dev/null 2>&1
          helm delete -n eyelevel $app-process > /dev/null 2>&1
          return 0
        fi
      done
      for app in "${golang_apps[@]}"; do
        if [[ "$dir" == */"$app" ]]; then
          helm delete -n eyelevel $app-cluster > /dev/null 2>&1
          return 0
        fi
      done
    fi
  else
    echo "Error: Directory '$dir' does not exist."
    exit 1
  fi
}

recurse_directories() {
  local do=$1
  local dir="$2"

  if [[ -d "$dir" ]]; then
    for sub_dir in "$dir"/*; do
      if [[ -d "$sub_dir" ]]; then
        $do "$sub_dir"
      fi
    done
  else
    echo "Error: Directory '$dir' does not exist."
    exit 1
  fi
}

do=deploy
if [[ "$CLEAR" -eq 1 ]]; then
  do=destroy
  reversed_groups=()

  for (( idx=${#valid_groups[@]}-1 ; idx>=0 ; idx-- )) ; do
      reversed_groups+=("${valid_groups[$idx]}")
  done

  valid_groups=("${reversed_groups[@]}")
fi

if [[ -n "$GROUP" ]]; then
  if [[ " ${valid_groups[@]} " =~ " $GROUP " ]]; then
    if [[ " ${recursive_types[@]} " =~ " $GROUP " ]]; then
      recurse_directories $do "operator/$GROUP"
    else
      $do "operator/$GROUP"
    fi
  else
    echo "Unknown request type: $GROUP"
    exit 1
  fi
elif [[ -n "$APP" ]]; then
  $do "operator/app/$APP"
elif [[ -n "$INIT" ]]; then
  $do "operator/init/$INIT"
elif [[ -n "$SERVICE" ]]; then
  $do "operator/services/$SERVICE"
else
  for dir in "${valid_groups[@]}"; do
    if [[ " ${recursive_types[@]} " =~ " $dir " ]]; then
      recurse_directories $do "operator/$dir"
    else
      $do "operator/$dir"
    fi
  done
fi