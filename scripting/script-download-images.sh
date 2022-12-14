#/bin/bash


VIB_REGISTRY_URI=hkacrallcardxprod001.azurecr.io

REGISTRY_MOBIO_URI="registry.mobio.vn"
REGISTRY_MOBIO_USER=vib
REGISTRY_MOBIO_PASS="Vib@$^*1357"

docker login -u="${REGISTRY_MOBIO_USER}" -p="${REGISTRY_MOBIO_PASS}" ${REGISTRY_MOBIO_URI}

IFS=$'\r\n' GLOBIGNORE='*' command eval  'list_module_info=($(cat $(pwd)/module.txt))'

function retag_image(){
    new_image=$(sed "s|${REGISTRY_MOBIO_URI}|${VIB_REGISTRY_URI}|g" <<< "$image")

    docker pull $image
}

for fields in ${list_module_info[@]}
do
    if [[ $fields == \#* ]]; then
        echo "ignored"
    elif [[ $fields == *0000* ]]; then
        echo "ignored"
    else
        IFS=$"|" read -r folder image <<< "$fields"
        echo "--- $folder ---"
        retag_image $folder $image
    fi
done

docker logout ${REGISTRY_MOBIO_URI}