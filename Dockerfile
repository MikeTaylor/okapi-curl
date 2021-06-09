FROM curlimages/curl:latest
COPY okapi-curl /bin/okapi-curl
ENTRYPOINT ["okapi-curl"]
