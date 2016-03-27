# docker-banana
Docker image for Banana.

### 1. Start Banana

```sh
$ docker run -d -p 9090:8080 --name banana mosuka/docker-banana:release-1.6
3f2efe1c75316e53b19e90df4c13210a16eac3b88e0c161c07ce05e883bed270
```

### 2. Check container ID

```sh
$ docker ps
CONTAINER ID        IMAGE                                 COMMAND                  CREATED             STATUS              PORTS                                         NAMES
3f2efe1c7531        mosuka/docker-solr:release-5.x        "/usr/local/bin/docke"   2 minutes ago       Up 2 minutes        7983/tcp, 18983/tcp, 0.0.0.0:8984->8983/tcp   solr
```

### 3. Get container IP

```sh
$ BANANA_CONTAINER_IP=$(docker inspect -f '{{ .NetworkSettings.IPAddress }}' banana)
$ echo ${BANANA_CONTAINER_IP}
172.17.0.7
```

### 4. Get host IP and port

```sh
$ BANANA_HOST_IP=$(docker-machine ip default)
$ echo ${BANANA_HOST_IP}
192.168.99.100

$ BANANA_HOST_PORT=$(docker inspect -f '{{ $port := index .NetworkSettings.Ports "8080/tcp" }}{{ range $port }}{{ .HostPort }}{{ end }}' banana)
$ echo ${BANANA_HOST_PORT}
9090
```

### 5. Open Solr Admin UI in a browser

```sh
$ BANANA_DASHBOARD=http://${BANANA_HOST_IP}:${BANANA_HOST_PORT}/banana/#/dashboard
$ echo ${BANANA_DASHBOARD}
http://192.168.99.100:9090/banana/#/dashboard
```

Open Banana Dashboard in a browser.
