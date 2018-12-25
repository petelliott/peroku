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

1. Build the client. ecl is the recomended implementation to build
   the project as it produces executables 1/5 the size of sbcl.

```
* (asdf:make :peroku-client)
```

2. Setup a dockerfile that will build and run your project on port 80

3. Setup a `.peroku.json` for your project. Tokens currently have no effect.

```json
{
    "token": "aksdfkldsjvieii",
    "peroku": "http://peroku.localhost",
    "project": "test-proj",
    "rule": "Host:test.localhost"
}
```

4. Deploy the project.

```bash
$ perok
$ perok .
```

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

Builds and runs a project. Returns the id of a websocket with build logs.
It is assumed the webapp you are running is on port 80

Example request:

| key       | description |
| --------- | ----------- |
| `project` | The name of the project. Used to identify it for future requests |
| `rule`    | the [traefik](https://traefik.io) rule to route to the host |
| `data`    | A base64 encoded tarfile that docker can build |

```json
{
    "project": "test",
    "rule": "Host:test.localhost",
    "data": "a2pzZGZsc2Rma3NkYWZsc2RmamtkZmxrZHNhZmxmbHNkZmRzZmtsZmFudm4gb2V"
}
```

Example response:

```json
{
    "logid": "joi5l8QZy2hIWzrQ"
}
```

#### [DELETE] /projects/:project

Stops and deletes `:project`

#### [GET] /logs/:logid

Connects to a log websocket. Logging endpoints are reuseable, but are not
persistant and may go away after some time.

### peroku client

The peroku client has not been implemented yet.

## dependencies

### peroku server

- [traefik](https://traefik.io)
- [my fork of cl-docker](https://github.com/Petelliott/cl-docker)
- [clack](https://github.com/fukamachi/clack)
- [ningle](https://github.com/fukamachi/ningle)
- [websocket-driver](https://github.com/Petelliott/websocket-driver) (using my fork temporarily)
- [cl-json](https://common-lisp.net/project/cl-json/cl-json.html)
- [cl-base64](http://quickdocs.org/cl-base64/)
- [bordeaux-threads](https://common-lisp.net/project/bordeaux-threads/)


### peroku client

The peroku client has not been implemented yet.
