# DNS Entries API

A simple API for storing DNS records (IP addresses) belonging to hostnames, developed with Ruby (v2.6.5) on Rails (v5.2.3).

**This is not meant to run as a production application.**

## Requirements
- [Docker][docker]
- [Docker Compose][docker-compose]
- [make]


## Getting Started

**Note:** These commands were tested in a Linux terminal.

1. Clone the repo.
    ```shell
    git clone https://github.com/ivamluz/DnsEntriesAPI.git
    cd DnsEntriesAPI
    ```
1. Create the `.env` file.
    ```shell
    cp .env.template .env
    ```
1. Update the `.env` file with the required values.
1. Start the services. The first run may take a few minutes as Docker images are pulled/built for the first time.
    ```shell
    make debug
    ```

1. Open http://localhost:3000 in a web browser. You should see the Rails welcome page


## Database setup

1. Check what container the application is running at. Run `docker ps` and take note of the ruby:2.6.5 container id. It should look similar to this:
```
$ docker ps
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                                              NAMES
734bbd53f0ca        ruby:2.6.5          "entrypoint.sh rails…"   23 seconds ago      Up 22 seconds       0.0.0.0:3000->3000/tcp                       
```

1. Apply migrations:
    ```shell
    docker exec 734bbd53f0ca rails db:migrate
    ```

7. Setup the `test` database:
    ```
    docker exec 734bbd53f0ca rails db:setup RAILS_ENV=test
    ```

## Run the test suite

```
docker exec 734bbd53f0ca rails test
```

## Testing the API
### Create some records

```sh
# Note: These commands were tested in a Linux terminal.

curl -XPOST \
  --header "Content-Type: application/json" \
  --header "Accept: application/json" \
  'http://localhost:3000/dns_records/' \
  -d @- << EOF
{ 
  "dns_records": { 
    "ip": "1.1.1.1", 
    "hostnames_attributes": [
      { "hostname": "lorem.com" },
      { "hostname": "ipsum.com" },
      { "hostname": "dolor.com" },
      { "hostname": "amet.com" }
    ] 
  }
}
EOF

curl -XPOST \
  --header "Content-Type: application/json" \
  --header "Accept: application/json" \
  'http://localhost:3000/dns_records/' \
  -d @- << EOF
{ 
  "dns_records": { 
    "ip": "2.2.2.2", 
    "hostnames_attributes": [
      { "hostname": "ipsum.com" }
    ] 
  }
}
EOF

curl -XPOST \
  --header "Content-Type: application/json" \
  --header "Accept: application/json" \
  'http://localhost:3000/dns_records/' \
  -d @- << EOF
{ 
  "dns_records": { 
    "ip": "3.3.3.3", 
    "hostnames_attributes": [
      { "hostname": "ipsum.com" },
      { "hostname": "dolor.com" },
      { "hostname": "amet.com" }
    ] 
  }
}
EOF

curl -XPOST \
  --header "Content-Type: application/json" \
  --header "Accept: application/json" \
  'http://localhost:3000/dns_records/' \
  -d @- << EOF
{ 
  "dns_records": { 
    "ip": "4.4.4.4", 
    "hostnames_attributes": [
      { "hostname": "ipsum.com" },
      { "hostname": "dolor.com" },
      { "hostname": "sit.com" },
      { "hostname": "amet.com" }
    ] 
  }
}
EOF

curl -XPOST \
  --header "Content-Type: application/json" \
  --header "Accept: application/json" \
  'http://localhost:3000/dns_records/' \
  -d @- << EOF
{ 
  "dns_records": { 
    "ip": "5.5.5.5", 
    "hostnames_attributes": [
      { "hostname": "sit.com" }
    ] 
  }
}
EOF
```

### Query the API
**Request**

```sh
curl 'http://localhost:3000/dns_records?included[]=ipsum.com&included[]=dolor.com&excluded[]=sit.com&page=1'
```

**Response**
```json
{
  "total_records": 2,
  "records": [
    {
      "id": 1,
      "ip_address": "1.1.1.1"
    },
    {
      "id": 3,
      "ip_address": "3.3.3.3"
    }
  ],
  "related_hostnames": [
    {
      "hostname": "amet.com",
      "count": 2
    },
    {
      "hostname": "lorem.com",
      "count": 1
    }
  ]
}
```

## TODOs
* Use `page` argument to paginate DB results.
* Check query performance with a bigger dataset.
* Check if there is a better place transform the DB result into the API format. This is currently done inside the DnsRecord model.


## Wrapping-up
When you're finished, stop the services.
```shell
make stop
```
##

## Additional Commands

All available commands can be seen by calling `make help`:
```sh
$ make help

Usage:
  make <target>

Targets:
  help                 Show help
  start                Start the services
  debug                Start the services in debug mode
  sql                  Start an interactive psql session (services must be running)
  logs                 Show the service logs (services must be running)
  stop                 Stop the services
  clear-db             Clear the sandbox and development databases
```

## Credits
The Docker Compose setup and the Makefile where inspired on [Plaid Pattern app][plaid].

[docker]: https://docs.docker.com/
[docker-compose]: https://docs.docker.com/compose/
[make]: http://man7.org/linux/man-pages/man1/make.1.html
[plaid]: https://github.com/plaid/pattern