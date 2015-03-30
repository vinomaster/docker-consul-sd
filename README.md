# Service Discovery with Docker and Consul
Service discovery test for multi-node cluster on a single host.

## Motivation
In a separate project, the migration from a working development environment to a production environment exposed issues with the portability of the service discovery topology using ```docker``` on a RHEL host. An alternative service discovery topology needed to be identified.

### Development Environment
A working service discovery topology:

* Single Host: Ubuntu 14.04 with [etcd](https://github.com/coreos/etcd) managing system-wide configuration data as key/value pairs.
* Multiple Docker Containers: Ubuntu 14.04 with [etcdctl](https://github.com/coreos/etcd) for fetching configuration data.

### Production Environment
A target service discovery topology:

* Single Host: RHEL (7.x) with [etcd](https://github.com/coreos/etcd) managing system-wide configuration data as key/value pairs.
* Multiple Docker Containers: Ubuntu 14.04 with [etcdctl](https://github.com/coreos/etcd) for fetching configuration data.

After exhaustive software version tests, OS setting changes (including tweaking SELinux), and playing with various ```etcd``` configuration settings; it was determined that this was not a viable target environment.

## Objective
Validate that service discovery on a single host (RHEL 7.x) between multiple docker containers (Ubuntu 14.04) is possible with an alternative Key/Value Storage tool.

## Approach
Explore the feasibility of using [Consul.io](http://www.consul.io/intro/index.html) for the Service Discovery Architecture.

1. Setup a RHEL 7.1 VM with latest version of Docker installed.
2. Create a Dcokerfile that will define a Ubuntu image with Consul.
3. Establish a sample test cluster of multiple Ubuntu nodes on the RHEL host.
4. Verify the communication between cluster nodes.

## Usage

### Prepare Environment

* ```make build```: Build the Ubuntu+Consul docker image.
* ```make test```: Construct Cluster

### Validate Environment

* ```docker ps -a```:
```
    ONTAINER ID        IMAGE                  COMMAND                CREATED             STATUS              PORTS                                                                            NAMES
7f4cc7a0eb3d        trusty/consul:latest   "/usr/local/sbin/con   11 seconds ago      Up 11 seconds       8600/udp, 0.0.0.0:8400->8400/tcp, 0.0.0.0:8500->8500/tcp, 0.0.0.0:8600->53/udp   node4
928b1558e775        trusty/consul:latest   "/usr/local/sbin/con   12 seconds ago      Up 11 seconds       8500/tcp, 8600/udp, 8400/tcp                                                     node3
b2f64a26371c        trusty/consul:latest   "/usr/local/sbin/con   12 seconds ago      Up 11 seconds       8400/tcp, 8500/tcp, 8600/udp                                                     node2
75487e146c81        trusty/consul:latest   "/usr/local/sbin/con   12 seconds ago      Up 12 seconds       8400/tcp, 8500/tcp, 8600/udp                                                     node1
```
* Attach to Node 4: Use [dockermenu](https://github.com/wedaa/dockermenu) to connect to Node 4.
* Query Cluster Details: ```consul members```
```
Node   Address           Status  Type    Build  Protocol
node4  172.17.0.89:8301  alive   client  0.3.1  2
node3  172.17.0.88:8301  alive   server  0.3.1  2
node1  172.17.0.86:8301  alive   server  0.3.1  2
node2  172.17.0.87:8301  alive   server  0.3.1  2
```
* Run Curl Tests:
```
curl -L http://localhost:8500/v1/kv/web/key1 -XPUT -d value="Hello world"
curl -L http://localhost:8500/v1/kv/web/key2 -XPUT -d value="Goodbye world"
curl -L http://localhost:8500/v1/kv/web/key1 -XGET
curl http://localhost:8500/v1/kv/web/?recurse
```

## Conclusion
Without having to do any linking at the ```docker``` command-level and without having to tweak any RHEL system settings, [Consul.io](http://www.consul.io/intro/index.html) provides a viable alternative to [etcd](https://github.com/coreos/etcd). Additionally, there is a vast set of [tools](http://www.consul.io/downloads_tools.html) that support Consul.

## Resources

* [Docker Ecosystem Diagram](http://comp.photo777.org/wp-content/uploads/2014/09/Docker-ecosystem-7.1.pdf)
* [Consul v. etcd](https://aphyr.com/posts/316-call-me-maybe-etcd-and-consul) is a great article on the status and capabilities of both Service Discovery solutions.
* [ConsulCtl](https://github.com/vinomaster/consulctl): A command line utility for Consul.
* **Easy Attach**: To simplify the tasks associated with attaching to a docker container on RHEL 7.x, see Eric Wedaa's [dockermenu](https://github.com/wedaa/dockermenu) which handles the ```nsenter``` commands for you.

```
    $ ./dockermenu
    1) node4
    2) node3
    3) node2
    4) node1
    Q) Quit
    Your Choice:
```
