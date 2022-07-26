#!/bin/bash

VIB_REGISTRY_URI=hkacrallcardxprod001.azurecr.io

REGISTRY_MOBIO_URI="registry.mobio.vn"

IFS=$'\r\n' GLOBIGNORE='*' command eval  'list_module_info=($(cat $(pwd)/module.txt))'


function apply_deploy() {
    #### delete
    #find $1 -name '*.yaml' -type f -exec kubectl delete -f {} -n mobio ';'
 
    #### apply
    find $1 -name '*.yaml' -type f -exec /bin/sh -c "sed \"s#{image}#${2}#g\" {} | kubectl apply -n mobio -f -" ';'
 
    #### restart
    #find $1 -name '*.yaml' -type f -exec kubectl rollout restart -f {} -n mobio ';'
 
    ### scale
    #find $1 -name '*.yaml' -type f -exec kubectl scale --replicas=0 -f {} -n mobio ';'
}

data=$(kubectl get deploy -n mobio --no-headers -o=custom-columns=NAME:.metadata.name,REPLICAS:.spec.replicas)

for fields in ${list_module_info[@]}
do
    if [[ $fields == \#* ]];
    then
        echo "ignored"
    else
        IFS=$"|" read -r folder image <<< "$fields"

        new_image=$(sed "s|${REGISTRY_MOBIO_URI}|${VIB_REGISTRY_URI}|g" <<< "$image")

        echo "--- $folder ---"
        apply_deploy $folder $new_image
    fi
done
