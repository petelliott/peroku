FROM ubuntu:18.04

RUN apt-get update && apt-get install -y sbcl curl libssl-dev

RUN curl -O https://beta.quicklisp.org/quicklisp.lisp && \
    sbcl --load quicklisp.lisp --eval '(quicklisp-quickstart:install)'\
    --eval '(ql-util:without-prompting (ql:add-to-init-file))' --quit

RUN sbcl --eval '(ql:quickload :clack)' --quit

COPY . /root/quicklisp/local-projects/peroku-example

RUN sbcl --eval '(ql:quickload :peroku-example)' --quit

CMD sbcl --eval '(ql:quickload :clack)' \
    --eval '(ql:quickload :peroku-example)' \
    --eval '(clack:clackup example:*app* :use-thread nil :port 80)' \
    --quit
