# okapi-curl

Copyright (C) 2020-2021 The Open Library Foundation

This software is distributed under the terms of the Apache License,
Version 2.0. See the file "[LICENSE](LICENSE)" for more information.

[`okapi-curl`](okapi-curl) is a light wrapper for [the `curl` command-line utility](https://curl.se/) that manages the tedious details of communicating with [the `okapi` API gateway](https://github.com/folio-org/okapi/) at the heart of [the FOLIO library services platform](https://www.folio.org/).


## Instructions

First, indicate what FOLIO service you want to access by specifying the URL and tenant of that service: edit the `.okapi` file in your home directory to contain something like:

	OKAPI_URL=https://folio-snapshot-okapi.dev.folio.org
	OKAPI_TENANT=diku

Now you can login: the result is an `OKAPI_TOKEN`, which is written to that file and will be used in subsequent operations:

	okapi-curl login

Now you can issue much simpler curl commands by using `okapi-curl`, for example:

	okapi-curl /copycat/profiles
	okapi-curl /copycat/profiles -d"{}"

If you provide the `-v` ("verbose") command-line option, then the `curl` command will be echoed rather than executed. This can be helpful for seeing what _would_ be done:

	okapi-curl -v /copycat/profiles

