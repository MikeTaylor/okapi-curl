# okapi-curl

Copyright (C) 2020-2021 The Open Library Foundation

This software is distributed under the terms of the Apache License,
Version 2.0. See the file "[LICENSE](LICENSE)" for more information.

[`okapi-curl`](okapi-curl) is a light wrapper for [the `curl` command-line utility](https://curl.se/) that manages the tedious details of communicating with [the `okapi` API gateway](https://github.com/folio-org/okapi/) at the heart of [the FOLIO library services platform](https://www.folio.org/).


## Setup

`okapi-curl` can work either with a configuration file in your home directory, or with environment variables. Environment variable values will override config file settings.

### Variables

These variables can be defined in either the configuration file (`~/.okapi`) or in the environment:

* `OKAPI_URL` (required): the base URL of the Okapi gateway
* `OKAPI_TENANT` (default `supertenant`): The tenant ID of the tenant of the Okapi service
* `OKAPI_TOKEN`: An authtoken for Okapi authorization
* `OKAPI_USER`: An username for Okapi authentication
* `OKAPI_PW`: A password for Okapi authentication

If `OKAPI_TOKEN` is present, `OKAPI_USER` and `OKAPI_PW` are ignored. If `OKAPI_USER` is present, `OKAPI_PW` is also required.

### Configuration file

The configuration file is a simple shell script for setting variable values that is sourced by `okapi-curl`. For example, to indicate what FOLIO service you want to access, specify the URL and tenant of that service. Edit the `.okapi` file in your home directory to contain something like:

	OKAPI_URL=https://folio-snapshot-okapi.dev.folio.org
	OKAPI_TENANT=diku

## Usage

    okapi-curl [-v] login|<path> [<curl-options>]

Using the `login` command (i.e. `okapi-curl login`) will prompt you for a username and password. On successful login, the `~/.okapi` file will be rewritten with the `OKAPI_URL`, `OKAPI_TENANT`, and `OKAPI_TOKEN` for use in subsequent operations.

If `OKAPI_TOKEN` or `OKAPI_USER` and `OKAPI_PW` are defined, you can issue much simpler curl commands using `okapi-curl`, for example:

	okapi-curl /copycat/profiles
	okapi-curl /copycat/profiles -d"{}"

If you provide the `-v` ("verbose") command-line option, then the `curl` command will be echoed rather than executed. This can be helpful for seeing what _would_ be done:

	okapi-curl -v /copycat/profiles

## Kubernetes deployment

The included [Dockerfile](Dockerfile) allows you to build a container suitable for use in Kubernetes CronJobs, e.g. for scheduling needed maintenance tasks in a FOLIO environment. This could be used, for example to run the `scheduled-age-to-lost` tasks for a [FOLIO Iris tenant](https://wiki.folio.org/display/REL/R1+2021+%28Iris%29+Release+Notes). A container image has been made available by [Index Data](https://www.indexdata.com) on [Docker Hub](https://hub.docker.com/r/indexdata/okapi-curl). Sample YAML manifests that use the container are included below.

Secret manifest for environment variables:
```
apiVersion: v1
kind: Secret
metadata:
  name: mytenant-age-to-lost-config
  namespace: mynamespace
type: Opaque
stringData:
  OKAPI_URL: "https://my-okapi.example.com"
  OKAPI_TENANT: "mytenant"
  OKAPI_USER: "ageToLost"
  OKAPI_PW: "**SECRET**"
```

CronJobs manifests:
```
---
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  name: mytenant-scheduled-age-to-lost
  namespace: mynamespace
spec:
  schedule: "*/30 * * * *"
  concurrencyPolicy: Forbid
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: mytenant-scheduled-age-to-lost
            image: indexdata/okapi-curl:latest
            envFrom:
            - secretRef:
                name: mytenant-age-to-lost-config
            args:
            - "/circulation/scheduled-age-to-lost"
            - "-X POST"
            - "--silent"
          restartPolicy: Never

---
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  name: mytenant-scheduled-age-to-lost-fee
  namespace: mynamespace
spec:
  schedule: "15,45 * * * *"
  concurrencyPolicy: Forbid
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: mytenant-scheduled-age-to-lost-fee
            image: indexdata/okapi-curl:latest
            envFrom:
            - secretRef:
                name: mytenant-age-to-lost-config
            args:
            - "/circulation/scheduled-age-to-lost-fee-charging"
            - "-X POST"
            - "--silent"
          restartPolicy: Never
```
