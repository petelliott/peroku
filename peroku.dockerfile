FROM ubuntu:18.04

RUN apt-get update && apt-get install -y sbcl curl git

RUN curl -O https://beta.quicklisp.org/quicklisp.lisp
RUN sbcl --load quicklisp.lisp --eval '(quicklisp-quickstart:install)'\
    --eval '(ql-util:without-prompting (ql:add-to-init-file))' --quit

#TODO: remove this when upstream websocket-driver is fixed
RUN git clone https://github.com/Petelliott/websocket-driver.git \
    /root/quicklisp/local-projects/websocket-driver

RUN git clone https://github.com/Petelliott/cl-docker.git \
    /root/quicklisp/local-projects/cl-docker

# preload some dependencies for better cacheing
# missing ones here will be added up when peroku is loaded
RUN sbcl \
    --eval '(ql:quickload :bordeaux-threads)' \
    --eval '(ql:quickload :docker)' \
    --eval '(ql:quickload :cl-base64)' \
    --eval '(ql:quickload :cl-json)' \
    --eval '(ql:quickload :websocket-driver-server)' \
    --quit

COPY peroku.asd /root/quicklisp/local-projects/peroku/peroku.asd
COPY peroku/ /root/quicklisp/local-projects/peroku/peroku/
RUN rm /root/quicklisp/local-projects/system-index.txt

# preload all of the dependancies
RUN sbcl --eval '(ql:quickload :peroku)' --quit


