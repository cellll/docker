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





