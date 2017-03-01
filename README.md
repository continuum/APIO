[![Build Status](https://semaphoreci.com/api/v1/continuum/apio/branches/master/badge.svg)](https://semaphoreci.com/continuum/apio)

# Development setup

## Requirements

- Docker
- Make
- An [editorconfig](http://editorconfig.org) plugin for your editor of choice.
- [voltos](https://voltos.io/) for the shared ENV variables.

## First run

Note: Only tested on Mac OS X and Linux so far.

Assuming you have a functional make and docker on your system, you only need to have
a few credentials for external dependencies (In Development this are now delivered in Voltos API-O bundle):

- Google Oauth2 client id and secrets (provided by hand for development)
- AWS key and secret for S3 storage (you can use your own on development)

Those should be set as environment variables (Or use Voltos in Development):

    $ export GOOGLE_OAUTH2_CLIENT_ID=<our-google-oauth2-client-id> GOOGLE_OAUTH2_CLIENT_SECRET=<our-google-oauth2-client-secret>
    $ export AWS_REGION=<aws-region> AWS_ACCESS_KEY_ID=<aws-key-id> AWS_SECRET_ACCESS_KEY=<aws-secret> S3_CODEGEN_BUCKET=<bucket-name>
    $ export SIGNER_API_TOKEN_KEY=<our-signer-key> SIGNER_API_SECRET=<our-signer-secret>

After those variables are set, you just need to run:

    $ make

...and go for coffee — it will take a while unless you have the right docker images cached. It will:

1. Build the docker images for the different containers (Ruby environment, NodeJS environment, PostgreSQL), and fetch all dependencies.

2. Create the PostgreSQL database and run database migrations.

3. Run all docker containers.

Note: The database migrations assumes that your postgres image have installed the "unaccent" extension, if you don't have it, install the postgresql-contrib package.

If you are on Mac OS X, you can now run `make mac-open` to auto-discover the IP of your docker machine and open a browser pointing to the web server. (If it doesn't work, take a look at the output of make and if everything looks OK then check `log/development.log` and `docker-compose logs` to debug the web application itself)

# Production Setup

Production runs on heroku. It is built from the master branch as part of the [continuous integration process](https://semaphoreci.com/continuum/apio) and automatically deployed to heroku. The image gives you a self-contained stateless web application that requires only some environment variables to run:

- `SECRET_KEY_BASE`: A random string that can be generated via `rails secret`. It should be the *same* for *every* instance running in production.

- `DATABASE_URL`: A pointer to the database (e.g: `postgres://myuser:mypass@localhost/somedatabase`).

- `GOOGLE_OAUTH2_CLIENT_ID`: Client ID to authenticate with Google OAuth2

- `GOOGLE_OAUTH2_CLIENT_SECRET`: Client Secret to authenticate with Google OAuth2

- `OAUTH_FULL_HOST`: URL for https://apio.continuum.cl

- `AWS_ACCESS_KEY_ID`: AWS Access Key, to use S3.

- `AWS_SECRET_ACCESS_KEY`: AWS Secret Access Key, to use S3.

- `AWS_REGION`: Region to use in S3 service.

- `S3_CODEGEN_BUCKET`: Pre-existing S3 Bucket where generated code (for API clients and server stubs) will be uploaded.


## Deployment

As the app is hosted in heroku, the deployment is automated in Semaphore by building the production image and deploying it using the `heroku-container-registry` plugin included in the heroku toolbelt.
A new release might include database changes, those changes are also executed by the Semaphore's deployment process, therefore is highly recommended to always build backwards compatible migrations.

# Managing and Upgrading Dependencies

With development, CI, and production all based on Docker, you don't need anything special to run this application other than `make`, `docker` and `docker-compose` (the latest only required on dev and CI).

While the dependencies are all encapsulated, it might be necessary to upgrade this dependencies in case of new features or security patches. Here is the detail of such dependencies and where they are specified (in case you want to specify a new one or upgrade an existing one).

## Base Operative System & Ruby Version

The base Docker image is specified on `Dockerfile` and `Dockerfile.development`. Both versions should be keep in sync. Also, the `bundle_cache` service on `docker-compose.yml` should use the same base image.

## System packages

System packages are installed via `apt-get` on the `Dockerfile` and `Dockerfile.development` files. Both files are mostly identical, except for the way in which the applicaton itself is built into the image (After the line that says `#Our app:`). If you need to add a new production dependency which is a system package, it should be added to both Dockerfiles.

## NodeJS

Node is installed from binaries fetched from the official distribution (not system packages). It is also specified on both `Dockerfile` and `Dockerfile.development` and should be keep in sync.

## Sway

A customized version of the nodejs sway packaged is used. The specific repository and commit are specified on both `Dockerfile` and `Dockerfile.development`. If a new version of sway should be used, both files should be changed in sync.

## PostgreSQL

On development, the version of the PostgreSQL docker image is specified on the `postgresql` service inside `docker-compose.yml`. If a new version is going to be run in production, the development version should also be changed there.

## Ruby Gems

As with any modern Ruby application, all Ruby libraries used by the application are specified in the `Gemfile` while the specific versions are automatically compiled by the `bundle` command into the `Gemfile.lock` file. If you want to upgrade a particular library while keeping the general specification in the `Gemfile`, use the `bundle update <gem-name>` command. If you want to do a major upgrade of a particular component (for example, migrating to a major version of Rails) you will need to change the `Gemfile`.
