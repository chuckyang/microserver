#!/bin/bash -i

dateYMD=`date +20%y%m%d`
routePath=/data/deploy/${dateYMD}
prodPath=/product/docker_mserver

arr=($1)

if [ ! $arr ]; then
  echo "arr IS NULL"
  exit
fi

mkdir -p ${routePath}

echo ${arr[@]}
for i in ${arr[*]}; do
    arr1=(${i/\:/\ })
    SERVICE_NAME=${arr1[0]}
    SERVICE_PORT=${arr1[1]}
    cp  ${routePath}/${SERVICE_NAME}.jar  ${prodPath}/
done
