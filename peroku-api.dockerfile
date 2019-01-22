FROM petelliott/peroku

# preload some dependencies for better cacheing
# missing ones here will be added up when peroku is loaded
RUN sbcl --eval '(ql:quickload :clack)' \
    --eval '(ql:quickload :ningle)' \
    --quit

COPY peroku-api.asd /root/quicklisp/local-projects/peroku/peroku-api.asd
COPY peroku-api/ /root/quicklisp/local-projects/peroku/peroku-api/
RUN rm /root/quicklisp/local-projects/system-index.txt

# preload all of the dependancies
RUN sbcl --eval '(ql:quickload :peroku-api)' --quit

CMD sbcl --eval "(ql:quickload '(:clack :peroku-api))" \
    --eval '(clack:clackup peroku.api.app:*app* :use-thread nil :port 80)' \
    --quit
