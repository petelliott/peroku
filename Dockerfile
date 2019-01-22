FROM ubuntu:18.04

RUN apt-get update && apt-get install -y sbcl curl git

RUN curl -O https://beta.quicklisp.org/quicklisp.lisp
RUN sbcl --load quicklisp.lisp --eval '(quicklisp-quickstart:install)'\
    --eval '(ql-util:without-prompting (ql:add-to-init-file))' --quit

RUN git clone https://github.com/Petelliott/cl-docker.git \
    /root/quicklisp/local-projects/cl-docker

#TODO: remove this when upstream websocket-driver is fixed
RUN git clone https://github.com/Petelliott/websocket-driver.git \
    /root/quicklisp/local-projects/websocket-driver

# preload some dependencies for better cacheing
# missing ones here will be added up when peroku is loaded
RUN sbcl --eval '(ql:quickload :clack)' \
    --eval '(ql:quickload :bordeaux-threads)' \
    --eval '(ql:quickload :ningle)' \
    --eval '(ql:quickload :docker)' \
    --eval '(ql:quickload :cl-base64)' \
    --eval '(ql:quickload :cl-json)' \
    --eval '(ql:quickload :websocket-driver-server)' \
    --quit

COPY peroku-api.asd /root/quicklisp/local-projects/peroku/peroku-api.asd
COPY peroku-api/ /root/quicklisp/local-projects/peroku/peroku-api/
COPY peroku.asd /root/quicklisp/local-projects/peroku/peroku.asd
COPY peroku/ /root/quicklisp/local-projects/peroku/peroku/

# preload all of the dependancies
RUN sbcl --eval '(ql:quickload :peroku-api)' --quit

CMD sbcl --eval "(ql:quickload '(:clack :peroku-api))" \
    --eval '(clack:clackup peroku.api.app:*app* :use-thread nil :port 80)' \
    --quit
