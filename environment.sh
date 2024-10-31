#!/usr/bin/env bash

. "${BASH_SOURCE%/*}/shared/util.sh"

must_have aws
must_have terraform

valid_envs=("aws")
recursive_types=("aws")

valid_aws=("eks" "cpu-memory" "cpu-only" "gpu-layout" "gpu-ranker" "gpu-summary")

ENV=""
AWS=""

if [[ "$1" =~ ^- ]]; then
  IN=""
else
  IN=$1
  shift

  if [[ " ${valid_envs[@]} " =~ " $IN " ]]; then
    ENV=$IN

    if [[ "$ENV" == "aws" ]]; then
      test_aws || { error "aws command isn't working (are you authorized?)"; exit 2; }
    fi
  elif [[ " ${valid_aws[@]} " =~ " $IN " ]]; then
    AWS=$IN

    test_aws || { error "aws command isn't working (are you authorized?)"; exit 2; }
  else
    { error "Unknown request type: [$IN]"; exit 1; }
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
      { error "Invalid option: [-$OPTARG]"; exit 1; }
      ;;
    :)
      { error "Option [-$OPTARG] requires an argument."; exit 1; }
      ;;
  esac
done

destroy() {
  local dir="$1"

  if [[ -d "$dir" ]]; then
    status "\u00b7 Destroying $dir" && echo
    if [[ "$TFLAG" -eq 1 ]]; then
      terraform -chdir="$dir" destroy
    else
      terraform -chdir="$dir" destroy --auto-approve
    fi
    status "Done"; ok;
  else
    { error "Error: Directory [$dir] does not exist."; exit 1; }
  fi
}

do=deploy
if [[ "$CLEAR" -eq 1 ]]; then
  do=destroy
  reversed_envs=()

  for (( idx=${#valid_envs[@]}-1 ; idx>=0 ; idx-- )) ; do
      reversed_envs+=("${valid_envs[$idx]}")
  done

  valid_envs=("${reversed_envs[@]}")
fi

if [[ -n "$ENV" ]]; then
  if [[ " ${valid_envs[@]} " =~ " $ENV " ]]; then
    if [[ " ${recursive_types[@]} " =~ " $ENV " ]]; then
      if [[ "$CLEAR" -ne 1 ]]; then
        if [[ "$ENV" == "aws" ]]; then
          $do "environment/$ENV"
        fi
      fi
      recurse_directories $do "environment/$ENV"
      if [[ "$CLEAR" -eq 1 ]]; then
        if [[ "$ENV" == "aws" ]]; then
          $do "environment/$ENV"
        fi
      fi
    else
      $do "environment/$ENV"
    fi
  else
    { error "Unknown request type: [$ENV]"; exit 1; }
  fi
elif [[ -n "$AWS" ]]; then
  if [[ "$AWS" == "eks" ]]; then
    $do "environment/aws"
  else
    $do "environment/aws/$AWS"
  fi
else
  #for dir in "${valid_envs[@]}"; do
  #  if [[ " ${recursive_types[@]} " =~ " $dir " ]]; then
  #    recurse_directories $do "environment/$dir"
  #  else
  #    $do "environment/$dir"
  #  fi
  #done
  echo 'all'
fi