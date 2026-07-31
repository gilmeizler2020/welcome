FROM pierrezemb/gostatic
COPY web/ /srv/http/
CMD ["-port","8080","-https-promote","-enable-logging"]
