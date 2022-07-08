#/bin/bash

VIB_REGISTRY_URI=hkacrallcardxprod001.azurecr.io

REGISTRY_MOBIO_URI="registry.mobio.vn"
REGISTRY_MOBIO_USER=vib
REGISTRY_MOBIO_PASS="Vib@$^*1357"

IFS=$'\r\n' GLOBIGNORE='*' command eval  'list_module_info=($(cat $(pwd)/module.txt))'

function retag_image(){
    new_image=$(sed "s|${REGISTRY_MOBIO_URI}|${VIB_REGISTRY_URI}|g" <<< "$image")

    docker tag $image $new_image
    docker push $new_image
    docker rmi $image
    docker rmi $new_image
}

for fields in ${list_module_info[@]}
do
    if [[ $fields == \#* ]];
    then
        echo "ignored"
    else
        IFS=$"|" read -r folder image <<< "$fields"
        echo "--- $folder ---"
        retag_image $folder $image
    fi
done
