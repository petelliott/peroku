## peroku

peroku is a platform for testing and deploying docker based webapps.
It is available under the AGPLv3

## quickstart

### peroku server

1. (optional -- you can use the docker hub versions) build the docker image

    ```bash
    $ docker build -t petelliott/peroku .
    ```

2. start traefik and peroku

    ```bash
    $ PEROKU_TOK=token docker-compose up -d
    ```

    If you want peroku to be exposed globally change `peroku.localhost` in
    docker-compose.yml to `peroku.your-domain.com`.

### peroku client

1. (optional -- see releases) Build the client. sbcl is currently the only
   supported client.

    ```
    * (asdf:make :peroku-client)
    ```

2. Setup a dockerfile that will build and run your project on port 80

3. Setup a `.peroku.json` for your project.

    ```json
    {
        "token": "aksdfkldsjvieii",
        "peroku": "peroku.localhost",
        "project": "test-proj",
        "rule": "Host:test.localhost"
    }
    ```

4. Deploy the project.

    ```bash
    $ perok noverify up
    Step 1/7 : FROM ubuntu:18.04
     ---> 16508e5c265d
    ...
    ```

    If you get `Bad gateway` when you request to your web service,
    wait a while or check the docker logs, because you server is probably
    still starting.

## let's encrypt

To use traefik's builtin let's encrypt support:

1. uncomment the following line in docker-compose.yml

    ```yml
          #- ./acme.json:/acme.json
    ```

2. uncomment the following lines in traefik.toml, setting it to your email

    ```toml
    #[acme]
    #email = "your-email-here@my-awesome-app.org"
    #storage = "acme.json"
    #entryPoint = "https"
    #onHostRule = true
    #[acme.httpChallenge]
    #entryPoint = "http"
    ```

3. create acme.json

    ```bash
    $ touch acme.json
    $ chmod 600 acme.json
    ```

for more information on let's encrypt, see
[this guide](https://docs.traefik.io/user-guide/docker-and-lets-encrypt/)

## travis-ci integration

you can deploy to peroku when all of your travis test pass.

add the following to your `.travis.yml`

```yml
deploy:
  provider: script
  script: curl https://raw.githubusercontent.com/Petelliott/peroku/master/deploy.sh | bash -s https://peroku.example.com peroku-example Host:example.example.com
  on:
    branch: master
```

follow the [travis
guide](https://docs.travis-ci.com/user/environment-variables/#defining-variables-in-repository-settings)
to add the `$PEROKU_TOK` environment variable.

see [travis script deployment
documentation](https://docs.travis-ci.com/user/deployment/script/) for more
configuration options.

see [Petelliott/peroku-example](https://github.com/Petelliott/peroku-example)
for a working example.

## api

### peroku server

Any endpoint marked with *secure* requires a token in the `Authorization` header

example:

```
Authorization: Bearer jnvnqovidkakienveivei
```

HTTP basic authentication can also be used with any username and the
token as the password.

```
Authorization: Basic YW55dGhpbmc6dG9rZW4=
```

Secure endpoints that recieve an invalid token, or no token
will return `403 Forbidden`. unauthorized websockets will disconnect with
the code `4001`.

#### [GET] /

Returns the current peroku version

Example response:

```
peroku 0.0.0
```

#### *secure* [GET] /list

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

#### *secure* [POST] /run

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

#### *secure* [DELETE] /projects/:project

Stops and deletes `:project`

#### *secure* [GET] /logs/:logid

Connects to a log websocket. Logging endpoints are reuseable, but are not
persistant and may go away after some time.

#### *secure* [GET] /projects/:project/logs

connects to the logs of the projects container as a websocket.

example messages:

```json
{"stream": "stdout", "data": "hello\n"}
{"stream": "stderr", "data": "ERROR\n"}
```

### peroku client

Prefix and command with noverify to prevent checking of ssl certificate
validity. This is useful when running on localhost or when not using let's
encrypt.

#### perok list

lists all running peroku projects and their associated rules

example output:

```
peroku-example      Host:example.localhost
test-project        Host:test.localhost
```

#### perok logs

follows the logs of the project. \<C-c\> to exit.

example output:

```
This is SBCL 1.4.5.debian, an implementation of ANSI Common Lisp.
More information about SBCL is available at <http://www.sbcl.org/>.

SBCL is free software, provided as is, with absolutely no warranty.
It is mostly in the public domain; some portions are provided under
BSD-style licenses.  See the CREDITS and COPYING files in the
distribution for more information.
To load "clack":
  Load 1 ASDF system:
    clack
; Loading "clack"
.
To load "peroku-example":
  Load 1 ASDF system:
    peroku-example
; Loading "peroku-example"

Hunchentoot server is going to start.
Listening on localhost:80.
^C
```

#### perok up

builds and runs the current project.
attaches to the docker build output and exits when finished.

example output:

```
Step 1/7 : FROM ubuntu:18.04
 ---> 16508e5c265d
Step 2/7 : RUN apt-get update && apt-get install -y sbcl curl libssl-dev
 ---> Running in f83e8e3e1991
Get:1 http://security.ubuntu.com/ubuntu bionic-security InRelease [83.2 kB]
Get:2 http://archive.ubuntu.com/ubuntu bionic InRelease [242 kB]
Get:3 http://security.ubuntu.com/ubuntu bionic-security/universe Sources [32.5 kB]
Get:4 http://security.ubuntu.com/ubuntu bionic-security/universe amd64 Packages [135 kB]
Get:5 http://security.ubuntu.com/ubuntu bionic-security/multiverse amd64 Packages [1367 B]
...
```

#### perok down

takes down a peroku project.

example output:

```
deleted peroku-example
```

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

- [cl-json](https://common-lisp.net/project/cl-json/cl-json.html)
- [cl-base64](http://quickdocs.org/cl-base64/)
- [bt-semaphore](https://github.com/rmoritz/bt-semaphore)
- [archive](https://github.com/froydnj/archive)
- [flexi-streams](https://edicl.github.io/flexi-streams/)
- [websocket-driver](https://github.com/Petelliott/websocket-driver) (using my fork temporarily)
- [cl-fad](https://edicl.github.io/cl-fad/)
- [dexador](https://github.com/fukamachi/dexador)
