# microserver

## shell params

### 单机版
需要传4个参数
1 service_arr  2 env  3 nat{true|false} 4  upload{true|false}
service_arr:微服务:端口，多个服务中间用空格隔开 如：ydt-ad-service:8096 ydt-cms-service:8098
env:运行环境 dev|itg|prod
nat:端口转发，只能设置为true|false。需要公开的服务则必须要把端口映射出来，规则是 -p A:A
upload:该服务是否需要上传资源，需要的话设置为true,默认上传路径为/product/docker_nginx/nginx_root/files

运行命令：${shell_path}/mserver_run.sh "${SERVICE_ARR}"  ${ENV_VALUE}  ${IS_NAT} ${IS_UPLOAD}

### 集群版
需要传6个参数
1 service_arr  2 env  3 overlay net 4 nat{true|false} 5 target host 6 upload{true|flase}
service_arr:微服务:端口，多个服务中间用空格隔开 如：ydt-ad-service:8096 ydt-cms-service:8098
env:运行环境 dev|itg|prod
overlay:集群网络，如果跨主机通讯则必须加入该网络。如：prod_net
nat:端口转发，只能设置为true|false。需要公开的服务则必须要把端口映射出来，规则是 -p A:A
target:指定主机名，即微服务指定发布到某台主机，不指定则由集群随机分发。如果不指定必须设置参数占位符为""。
upload:该服务是否需要上传资源，需要的话设置为true,默认上传路径为/product/docker_nginx/nginx_root/files

运行命令：${shell_path}/mserver_swarm_arr_net.sh "${SERVICE_ARR}"  ${ENV_VALUE} ${OVERLAY_NET}  ${IS_NAT} ${TARGET_HOST} ${IS_UPLOAD} 
