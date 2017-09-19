# Redis

[Redis](https://redis.io/) is an open source \(BSD licensed\), in-memory data structure store, used as a database, cache and message broker. It supports data structures such as strings, hashes, lists, sets, sorted sets with range queries, bitmaps, hyperloglogs and geospatial indexes with radius queries. Redis has built-in replication, Lua scripting, LRU eviction, transactions and different levels of on-disk persistence, and provides high availability via Redis Sentinel and automatic partitioning with Redis Cluster.

## DistributedCache Architecture

Every traffic server start up 2 redis server instance\(DistributedCacheA and DistributedCacheB\),  
every SSM start up 1 server instance\(DistributedCacheCtrlAssistant\) and 1 redis cluster maintain daemon\(DistributedCacheCtrl\),  
only one DistributedCacheCtrl daemon is elected to be run using master election mechanism.  
DistributedCacheCtrl daemon will automatically add new redis server into cluster with help of  
consul service discovery mechanism, automatically remove fail nodes from cluster.  
![](./architecture.png)

## How DistributedCacheCtrl Manage A Cluster

1. Get all redis instance via consul, then join all of them to form a cluster, if none of them is up, it keep sleeping and check again
2. Remove failure redis servers
3. Assign role for redis servers, redis server's initial rolse is master:
   * if there are 2 masters, and both of them have no slave, and they don't locate on same host, then pair them 
4. For slots that no server are serving\(this happen when a pair of redis server are down\), it assign those slots to existing master averagely, slots will not be assigend to DistributedCacheCtrlAssistant instance
5. For servers that serving more than average slots, move exceeding average slots to master that have no slots, total moved slot will not exceed average slots
6. Reset slaves who can't become master after its master is down
7. Above step1-6 repeat every 30s

## Trouble Shooting

* cmd to check cluster state on TS:
  > sdc  -h  \`getip internal-data-network\`

or on SSM:

> sdc  -h  \`getip internal-data-network\` -p 6380

```
    172.17.52.80:6378> cluster info
    cluster_state:ok
    cluster_slots_assigned:16384
    cluster_slots_ok:16384
    cluster_slots_pfail:0
    cluster_slots_fail:0
    cluster_known_nodes:17
    cluster_size:6
    cluster_current_epoch:372
    cluster_my_epoch:372
    cluster_stats_messages_sent:3237
    cluster_stats_messages_received:1474
    172.17.52.80:6378> cluster nodes
    0890b462a3a2c6727be9665b0faead125328a29d 172.17.52.82:6378 master - 0 1492765546527 0 connected
    6e18a44a89373a6cf1a29a182850416eb338c647 172.17.52.79:6378 master - 0 1492765546922 366 connected 5462-8192
    9a3239cb74a739a0be571ff39475733463ed5d32 172.17.52.121:6380 master - 0 1492765546926 131 connected
    164475cb9f6c359894664636621cf05b293af730 172.17.52.105:6378 master - 0 1492765545018 367 connected 2731-5461
    118556ab4ee7521895c701e8a521fc19fc2ff233 172.17.52.80:6379 slave f94a3a076271095949ee2d2ab228f025627b50d6 0 1492765546421 371 connected
    0e75168cc7a46f8bd90daf86fe7e01c50d4c8a67 172.17.52.87:6379 slave 946b5ac25d688263f80862d418a2e56e7872ec82 0 1492765545419 369 connected
    9d882031f65b648980606b1461592ca2d1eb74a4 172.17.52.82:6379 master - 0 1492765546922 373 connected
    dd28bc03567c8f0c44bc4b5f6045af8de4cad531 172.17.52.123:6380 master - 0 1492765545419 138 connected
    518e3469bc2f4ebaf2c07ac011bde00fc58b8b74 172.17.52.81:6379 slave 7a0e1738b24bd293b6f801b71961fa809f3e4129 0 1492765546522 363 connected
    89a1f8fd53bc0275b9befd0aaef27f922ae22adb 172.17.52.79:6379 slave d52b5266f33c9d93e285cfa9904948c8c56f670a 0 1492765546421 372 connected
    b542170c683461d7e8f3843a84f254b29cc1bc2c 172.17.52.122:6380 master - 0 1492765544917 132 connected
    6d6946536390445e83176b8794dba929fd307c45 172.17.52.105:6379 slave 6e18a44a89373a6cf1a29a182850416eb338c647 0 1492765545419 368 connected
    7a0e1738b24bd293b6f801b71961fa809f3e4129 172.17.52.87:6378 master - 0 1492765546121 363 connected 13655-16383
    d52b5266f33c9d93e285cfa9904948c8c56f670a 172.17.52.80:6378 myself,master - 0 0 372 connected 8193-10923
    f94a3a076271095949ee2d2ab228f025627b50d6 172.17.52.81:6378 master - 0 1492765545520 0 connected 10924-13654
    760e4d8e95e666c7873c7506e9614461e642867d 172.17.52.104:6379 slave 164475cb9f6c359894664636621cf05b293af730 0 1492765546522 367 connected
    946b5ac25d688263f80862d418a2e56e7872ec82 172.17.52.104:6378 master - 0 1492765546421 369 connected 0-2730
```

* Logs

  **TS:**  
    /var/log/ses/distributedcache/distributedcachea.log  
    /var/log/ses/distributedcache/distributedcacheb.log

  **SSM:**  
    /var/log/ses/distributedcache/clustertool.log  
    /var/log/ses/service/sdcctrl.log  
    /var/log/ses/distributedcache/distributedcachectrlassistant.log



