<pre><code>
</code></pre>

### Docker container내부 디스플레이 연결

컨테이너 빌드 시 
<pre><code>apt-get install -y libcanberra-gtk-module packagekit-gtk3-module
</code></pre>

컨테이너 실행 시 
<pre><code>-v /tmp/.X11-unix:/tmp/.X11-unix
-e DISPLAY=$DISPLAY 
</code></pre>


### container 삭제

모두 삭제 

<pre><code>docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q)
docker ps -a
</code></pre>
exited만 삭제
<pre><code>docker rm $(docker ps -q -f status=exited)
</code></pre>

### privileged 에러 해결
<pre><code>setenforce 0
</code></pre>


### Nvidia runtime
nvidia-container-runtime 설치 후 <br>
/etc/docker/daemon.json 파일 내용 추가
<pre><code>{
    "default-runtime": "nvidia",
    "runtimes": {
        "nvidia": {
            "path": "/usr/bin/nvidia-container-runtime",
            "runtimeArgs": []
        }
    }
}
</code></pre>

<pre><code>sudo pkill -SIGHUP dockerd
sudo systemctl daemon-reload
sudo systemctl restart docker
</code></pre>




# Docker swarm, compose inference 배포 테스트


##### 테스트 환경

Ubuntu 16.04.1 LTS (Xenial Xerus) <br>
docker version 18.03.0-ce, build 0520e24 <br>
nvidia-docker2=2.0.3+docker18.03.0-1 <br>
nvidia-smi 390.25 <br>
cuda 8.0 <br>
cudnn 6.0 <br>


##### Every node
```
apt-get install -y nvidia-container-runtime

sudo tee /etc/docker/daemon.json <<EOF
{
    "runtimes": {
        "nvidia": {
            "path": "/usr/bin/nvidia-container-runtime",
            "runtimeArgs": []
        }
    }
}
EOF
sudo pkill -SIGHUP dockerd

sudo systemctl daemon-reload
sudo systemctl restart docker
```

```
docker pull wurstmeister/zookeeper
docker pull xiilab/kafka
docker pull xiilab/dist_inference
```




## Docker compose : distributed inference in single node


### docker-compose.yml

```
    kafka:
        ...
        environment:
        KAFKA_ADVERTISED_HOST_NAME: $(IP)
        ...
    inference:
        image: xiilab/dist_inference
        ...
        environment:
            KAFKA_BROKER: $(IP):39092
            GPU_MEMORY_FRACTION: (0.1 ~ 1)
        ...            
        volumes:
        - $(result_dir):/root/result

```

##### usage
> mkdir /root/result<br>
> docker-compose up --scale inference=4<br>
> python kafka_producer.py $(IP):39092 testtopic<br>
> /root/result<br>


---

## distributed inference in multi node (swarm mode)

### master node 

> docker swarm init

![Alt](/img/docker_swarm_init.png)


### slave node

> docker swarm join --token SWMTKN-1-3dvwm2lzqoh02ae2jvn2qv724g63zsbgko3iq0r4ym3tv24zow-7bi5i6qozb8ww945hkklzyfs7 192.168.1.91:2377

![Alt](/img/docker_swarm_join.png)

### master node

> docker node ls  :  swarm 연결 확인

![Alt](/img/docker_node_ls.png)



### docker-swarm.yml

```
version: '3.2'
services:
  zookeeper:
    ...
    deploy:
      placement:
        constraints:
          - node.hostname == ${SWARM_MASTER_HOSTNAME}
    ...
    
  kafka:
    ...
    deploy:
      placement:
        constraints:
          - node.hostname == ${SWARM_MASTER_HOSTNAME}
    ...
    environment:
      KAFKA_ADVERTISED_HOST_NAME: ${SWARM_MASTER_IP}
      KAFKA_ZOOKEEPER_CONNECT: zookeeper:2181
      KAFKA_CREATE_TOPICS: "${KAFKA_TOPIC}:4:1"
    ...
  inference:
    ...
    deploy:
      replicas: ${INFERENCE_CONTAINER_REPLICAS}
    environment:
      KAFKA_BROKER: ${SWARM_MASTER_IP}:39092
      KAFKA_TOPIC: ${KAFKA_TOPIC}
      KAFKA_CONSUMER_GROUP: ${KAFKA_GROUP}
      KAFKA_TOPIC_PART: ${INFERENCE_CONTAINER_REPLICAS}
      GPU_MEMORY_FRACTION: ${MEMORY_FRACTION}
    ...

volumes:
  nvidia_driver_390_25:
    external: true

```

### usage

> docker stack deploy -c docker-swarm.yml ${SERVICE_NAME}<br>
> python kafka_producer.py ${SWARM_MASTER_IP}:39092 ${KAFKA_TOPIC}<br>
> /root/result/-.txt 결과 확인


### link
https://drive.google.com/file/d/1TdrFgCd8engtJAWcaq47MvtBbuMdHw8r/view?usp=sharing<br>
https://github.com/wurstmeister/kafka-docker
