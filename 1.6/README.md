# docker-banana

This is a Docker image for Banana.

## What is Banana?

The [Banana](https://github.com/lucidworks/banana) project was forked from Kibana, and works with all kinds of time series (and non-time series) data stored in Apache Solr. It uses Kibana's powerful dashboard configuration capabilities, ports key panels to work with Solr, and provides significant additional capabilities, including new panels that leverage D3.js.

Learn more about Banana on the [Banana project](https://github.com/lucidworks/banana).

## How to use this Docker image

### Banana example

#### 1. Start Solr

Run Solr.

See [https://github.com/mosuka/docker-solr/tree/master/5.5](https://github.com/mosuka/docker-solr/tree/master/5.5).

#### 2. Start Banana

```sh
$ docker run -d -p 5602:5601 --name banana mosuka/docker-banana:release-1.6
3f2efe1c75316e53b19e90df4c13210a16eac3b88e0c161c07ce05e883bed270
```

#### 3. Check container ID

```sh
$ docker ps
CONTAINER ID        IMAGE                                 COMMAND                  CREATED             STATUS              PORTS                                         NAMES
98716340f302        mosuka/docker-banana:release-1.6      "/usr/local/bin/docke"   50 seconds ago      Up 6 seconds        0.0.0.0:5602->5601/tcp                        banana
```

#### 4. Get container IP

```sh
$ BANANA_CONTAINER_IP=$(docker inspect -f '{{ .NetworkSettings.IPAddress }}' banana)
$ echo ${BANANA_CONTAINER_IP}
172.17.0.9
```

#### 5. Get host IP and port

```sh
$ BANANA_HOST_IP=$(docker-machine ip default)
$ echo ${BANANA_HOST_IP}
192.168.99.100

$ BANANA_HOST_PORT=$(docker inspect -f '{{ $port := index .NetworkSettings.Ports "5601/tcp" }}{{ range $port }}{{ .HostPort }}{{ end }}' banana)
$ echo ${BANANA_HOST_PORT}
5602
```

#### 6. Open Solr Admin UI in a browser

```sh
$ BANANA_DASHBOARD=http://${BANANA_HOST_IP}:${BANANA_HOST_PORT}/banana/#/dashboard
$ echo ${BANANA_DASHBOARD}
http://192.168.99.100:5602/banana/#/dashboard
```

Open Banana Dashboard in a browser.

#### 7. Create a core for indexing the httpd logs. (If it connect to Standalone Solr.)

```sh
$ CORE_NAME=httpd_logs
$ CONFIG_SET=data_driven_schema_configs
$ DATA_DIR=data
$ curl -s "http://${SOLR_HOST_IP}:${SOLR_HOST_PORT}/solr/admin/cores?action=CREATE&name=${CORE_NAME}&configSet=${CONFIG_SET}&dataDir=${DATA_DIR}" | xmllint --format -
<?xml version="1.0" encoding="UTF-8"?>
<response>
  <lst name="responseHeader">
    <int name="status">0</int>
    <int name="QTime">2944</int>
  </lst>
  <str name="core">collection1</str>
</response>

$ curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":{
     "name":"event_timestamp",
     "type":"date",
     "indexed":"true",
     "stored":"true",
     "multiValued":false },
  "add-field":{
     "name":"message",
     "type":"string",
     "indexed":"true",
     "stored":"true",
     "multiValued":false }
}' "http://${SOLR_HOST_IP}:${SOLR_HOST_PORT}/solr/${CORE_NAME}/schema"
{
  "responseHeader":{
    "status":0,
    "QTime":155}}
```

#### 7. Create a collecton for indexing the httpd logs. (If it connect to SolrCloud.)

```sh
$ COLLECTION_NAME=httpd_logs
$ NUM_SHARDS=2
$ COLLECTION_CONFIG_NAME=data_driven_schema_configs
$ REPLICATION_FACTOR=2
$ MAX_SHARDS_PER_NODE=10
$ CREATE_NODE_SET=$(echo $(curl -s "http://${SOLR_HOST_IP}:${SOLR_1_HOST_PORT}/solr/admin/collections?action=CLUSTERSTATUS&wt=json" | jq -r ".cluster.live_nodes[]") | sed -e 's/ /,/g')
$ curl -s "http://${SOLR_HOST_IP}:${SOLR_1_HOST_PORT}/solr/admin/collections?action=CREATE&name=${COLLECTION_NAME}&numShards=${NUM_SHARDS}&replicationFactor=${REPLICATION_FACTOR}&maxShardsPerNode=${MAX_SHARDS_PER_NODE}&createNodeSet=${CREATE_NODE_SET}&collection.configName=${COLLECTION_CONFIG_NAME}" | xmllint --format -
<?xml version="1.0" encoding="UTF-8"?>
<response>
  <lst name="responseHeader">
    <int name="status">0</int>
    <int name="QTime">8374</int>
  </lst>
  <lst name="success">
    <lst>
      <lst name="responseHeader">
        <int name="status">0</int>
        <int name="QTime">6510</int>
      </lst>
      <str name="core">httpd_logs_shard2_replica1</str>
    </lst>
    <lst>
      <lst name="responseHeader">
        <int name="status">0</int>
        <int name="QTime">6952</int>
      </lst>
      <str name="core">httpd_logs_shard2_replica2</str>
    </lst>
    <lst>
      <lst name="responseHeader">
        <int name="status">0</int>
        <int name="QTime">7466</int>
      </lst>
      <str name="core">httpd_logs_shard1_replica2</str>
    </lst>
    <lst>
      <lst name="responseHeader">
        <int name="status">0</int>
        <int name="QTime">7978</int>
      </lst>
      <str name="core">httpd_logs_shard1_replica1</str>
    </lst>
  </lst>
</response>

$ curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":{
     "name":"event_timestamp",
     "type":"date",
     "indexed":"true",
     "stored":"true",
     "multiValued":false },
  "add-field":{
     "name":"message",
     "type":"string",
     "indexed":"true",
     "stored":"true",
     "multiValued":false }
}' "http://${SOLR_HOST_IP}:${SOLR_1_HOST_PORT}/solr/${COLLECTION_NAME}/schema"
{
  "responseHeader":{
    "status":0,
    "QTime":155}}
```

#### 8. Create a core for Banana settings. (If it connect to Standalone Solr.)

```sh
$ CORE_NAME=bananaconfig
$ CONFIG_SET=data_driven_schema_configs
$ DATA_DIR=data
$ curl -s "http://${SOLR_HOST_IP}:${SOLR_HOST_PORT}/solr/admin/cores?action=CREATE&name=${CORE_NAME}&configSet=${CONFIG_SET}&dataDir=${DATA_DIR}" | xmllint --format -
<?xml version="1.0" encoding="UTF-8"?>
<response>
  <lst name="responseHeader">
    <int name="status">0</int>
    <int name="QTime">2944</int>
  </lst>
  <str name="core">collection1</str>
</response>

$ curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":{
     "name":"user",
     "type":"string",
     "indexed":"true",
     "stored":"true",
     "multiValued":false },
  "add-field":{
     "name":"group",
     "type":"string",
     "indexed":"true",
     "stored":"true",
     "multiValued":false },
  "add-field":{
     "name":"title",
     "type":"string",
     "indexed":"true",
     "stored":"true",
     "multiValued":false },
  "add-field":{
     "name":"dashboard",
     "type":"string",
     "indexed":"false",
     "stored":"true",
     "multiValued":false }
}' "http://${SOLR_HOST_IP}:${SOLR_HOST_PORT}/solr/${CORE_NAME}/schema"
{
  "responseHeader":{
    "status":0,
    "QTime":155}}
```

#### 8. Create a collection for Banana settings. (If it connect to SolrCloud.)

```sh
$ COLLECTION_NAME=bananaconfig
$ NUM_SHARDS=2
$ COLLECTION_CONFIG_NAME=data_driven_schema_configs
$ REPLICATION_FACTOR=2
$ MAX_SHARDS_PER_NODE=10
$ CREATE_NODE_SET=$(echo $(curl -s "http://${SOLR_HOST_IP}:${SOLR_1_HOST_PORT}/solr/admin/collections?action=CLUSTERSTATUS&wt=json" | jq -r ".cluster.live_nodes[]") | sed -e 's/ /,/g')
$ curl -s "http://${SOLR_HOST_IP}:${SOLR_1_HOST_PORT}/solr/admin/collections?action=CREATE&name=${COLLECTION_NAME}&numShards=${NUM_SHARDS}&replicationFactor=${REPLICATION_FACTOR}&maxShardsPerNode=${MAX_SHARDS_PER_NODE}&createNodeSet=${CREATE_NODE_SET}&collection.configName=${COLLECTION_CONFIG_NAME}" | xmllint --format -
<?xml version="1.0" encoding="UTF-8"?>
<response>
  <lst name="responseHeader">
    <int name="status">0</int>
    <int name="QTime">6392</int>
  </lst>
  <lst name="success">
    <lst>
      <lst name="responseHeader">
        <int name="status">0</int>
        <int name="QTime">5702</int>
      </lst>
      <str name="core">bananaconfig_shard2_replica1</str>
    </lst>
    <lst>
      <lst name="responseHeader">
        <int name="status">0</int>
        <int name="QTime">5782</int>
      </lst>
      <str name="core">bananaconfig_shard1_replica1</str>
    </lst>
    <lst>
      <lst name="responseHeader">
        <int name="status">0</int>
        <int name="QTime">6042</int>
      </lst>
      <str name="core">bananaconfig_shard2_replica2</str>
    </lst>
    <lst>
      <lst name="responseHeader">
        <int name="status">0</int>
        <int name="QTime">6141</int>
      </lst>
      <str name="core">bananaconfig_shard1_replica2</str>
    </lst>
  </lst>
</response>

$ curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":{
     "name":"user",
     "type":"string",
     "indexed":"true",
     "stored":"true",
     "multiValued":false },
  "add-field":{
     "name":"group",
     "type":"string",
     "indexed":"true",
     "stored":"true",
     "multiValued":false },
  "add-field":{
     "name":"title",
     "type":"string",
     "indexed":"true",
     "stored":"true",
     "multiValued":false },
  "add-field":{
     "name":"dashboard",
     "type":"string",
     "indexed":"false",
     "stored":"true",
     "multiValued":false }
}' "http://${SOLR_HOST_IP}:${SOLR_1_HOST_PORT}/solr/${COLLECTION_NAME}/schema"
{
  "responseHeader":{
    "status":0,
    "QTime":942}}
```

#### 8. Stop Banana

```sh
$ docker stop banana
banana

$ docker rm banana
banana
```