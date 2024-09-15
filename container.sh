#!/usr/bin/env bash

must_have() {
    for cmd in $*; do
        command -v $cmd >/dev/null 2>&1 || { error "$cmd command is required but not installed"; exit 1; }
    done
}

error() { echo -e >&2 "$@ \e[31;1m\u2717\e[0m"; }

status() { echo -ne "\e[37;1m$@: \e[0m"; }

ok() {
    [[ "$@" != "" ]] && echo -n "$@ "
    echo -e "\e[32;1m\u2713\e[0m"
}

warn() { echo -e "$@ \e[33;1m\u26a0\e[0m"; }

test_aws() {
    aws lambda list-functions > /dev/null 2>&1

    return $?
}

pre_check() {
    test_aws || { error "aws command isn't working (are you authorized?)"; return 2; }
}

create_container_bundle() {
    local container_name=$1
    local bundle_dir=$2

    files="bootstrap"

    for f in ${EXTRA_FILES_CONTAINER[$container_name]}; do
        if [ ! -e "$f" ]; then
            error "extra file '$f' does not exist, aborting"
            return 2
        fi
        mkdir -p "$bundle_dir/$(dirname $f)"
        cp "$f" "$bundle_dir/$f"
        files="$files $f"
    done

    echo -n "$files "
}

get_containers() {
    top="$(git rev-parse --show-toplevel)"
    echo "$top/modules/busybox/container $top/modules/opensearch/container $top/modules/redis/container "
    echo "$top "
}

must_have git

build_command="buildx build"
build_flag=true
container_dirs="."
push_flag=true
repo_target=""
target="linux/amd64,linux/arm64"

while [[ $# -gt 0 ]]
do
    case $1 in
    -no-build|-b)
      build_flag=false
      shift
    ;; 
    -no-push|-n)
      push_flag=false
      shift
    ;;
    -repo|-r)
        case $2 in
            *)
                repo_target=$2
                shift 2
            ;;
        esac
    ;;
    -target)
        case $2 in
            arm64|linux/arm64)
                target="linux/arm64"
                build_command="build"
                shift 2
            ;;
            amd64|linux/amd64)
                target="linux/amd64"
                build_command="build"
                shift 2
            ;;
            all|linux/all)
                target="linux/amd64,linux/arm64"
                build_command="buildx build"
                shift 2
            ;;
            *)
                echo "Invalid target: $2"
                exit 1
            ;;
        esac
    ;;
    -all|-a)
        container_dirs=$(get_containers)
        shift
    ;;
    *)
        error "unknown option: $1"
        exit 1
    ;;
    esac
done

echo

if [ -n "$repo_target" ]; then
    status "\u00b7 Only Build Target" && echo "${repo_target}" && echo
fi

status "\u00b7 System pre-flight check"
pre_check && { ok; } || exit 2

status "\u00b7 Login to public.ecr.aws"
aws ecr-public get-login-password --region us-east-1 | docker login --username AWS --password-stdin public.ecr.aws
echo

for container_dir in $container_dirs; do
    pushd "$container_dir" > /dev/null
    container_name="${PWD##*/}"

    status "\u00b7 [$container_name]"
    status "checking for Dockerfiles"
    if ls "$container_dir"/Dockerfile.* > /dev/null 2>&1; then
        ok && echo
        for dockerfile in "$container_dir"/Dockerfile.*; do
            file_name=$(basename "$dockerfile")
            repo_name=${file_name#Dockerfile.}

            if [ -n "$repo_target" ] && [ "$repo_target" != "$repo_name" ]; then
                continue
            fi

            pushd "$container_dir" > /dev/null
            status "\t\u00b7 [$repo_name]\tBuilding"
            if [ "$build_flag" = true ]; then
                echo $'\t\t' "docker $build_command --platform $target -f $file_name -t public.ecr.aws/c9r4x6y5/eyelevel/$repo_name:latest ." && echo
                docker $build_command --platform $target -f $file_name -t public.ecr.aws/c9r4x6y5/eyelevel/$repo_name:latest . && echo
                status "\tBuilt" && ok && echo
            else
                warn "skipping" && echo
            fi

            status "\t\u00b7 [$repo_name]\tPushing"
            if [ "$push_flag" = true ]; then
                echo $'\t\t' "docker push public.ecr.aws/c9r4x6y5/eyelevel/$repo_name:latest" && echo

                docker push public.ecr.aws/c9r4x6y5/eyelevel/$repo_name:latest && echo
                
                status "\tPushed" && ok
            else
                warn "skipping"
            fi

            popd > /dev/null && echo && echo
        done
    else
        warn "doesn't have Dockerfiles, skipping" && echo && echo
        popd > /dev/null
        continue
    fi
done

exit 0
