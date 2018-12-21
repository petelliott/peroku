## peroku

peroku is a platform for testing and deploying docker based webapps.
It is available under the AGPLv3

## quickstart

### peroku server

1. build the docker image

```bash
$ docker build -t peroku .
```

2. start traefik and peroku

```bash
$ docker-compose up -d
```

If you want peroku to be exposed globally change `peroku.localhost` in
docker-compose.yml to `peroku.your-domain.com`.

### peroku client

The peroku client has not been implemented yet.

## api

### peroku server

#### [GET] /

Returns the current peroku version

Example response:

```
peroku 0.0.0
```

#### [GET] /list

Lists all currently running projects

```json
[
    {
        "project": "test",
        "rule": "Host:test.localhost"
    },
    {
        "project": "test2",
        "rule": "Host:test2.localhost"
    }
]
```

#### [POST] /run

Builds and runs a project. It is assumed the webapp you are running is on port 80

Example request:

| key       | description |
| --------- | ----------- |
| `project` | The name of the project. Used to identify it for future requests |
| `rule`    | the [traefik](traefik.io) rule to route to the host |
| `data`    | A base64 encoded tarfile that docker can build |

```json
{
    "project": "test",
    "rule": "Host:test.localhost",
    "data": "a2pzZGZsc2Rma3NkYWZsc2RmamtkZmxrZHNhZmxmbHNkZmRzZmtsZmFudm4gb2V"
}
```

Example response:

*Note*: this is subject to change when websocket logs are implemented.

```json
{
    "Id": "c1b1e894a0ddfe8f8b05d60d45e191ce060dd3239225d1f7a4f6e42df04376a6",
    "Warnings": null
}
```

#### [DELETE] /projects/:project

Stops and deletes `:project`

### peroku client

The peroku client has not been implemented yet.

## dependencies

### peroku server

- [traefik](traefik.io)
- [my fork of cl-docker](https://github.com/Petelliott/cl-docker)
- [clack](https://github.com/fukamachi/clack)
- [ningle](https://github.com/fukamachi/ningle)
- [websocket-driver](https://github.com/fukamachi/websocket-driver)
- [cl-json](https://common-lisp.net/project/cl-json/cl-json.html)
- [cl-base64](http://quickdocs.org/cl-base64/)
- [bordeaux-threads](https://common-lisp.net/project/bordeaux-threads/)


### peroku client

The peroku client has not been implemented yet.
