# Getting things up and running

First thing to do is install the needed build environment to get your local machine ready to run everything. In the following, it is assumed that you are running on a Mac since that is needed to build the iOS client which will 
eventually be used to run the surveys defined in the researcher-ui.

## Install build environment

Install [Xcode](https://developer.apple.com/download/). If you complete this step, including opening Xcode at least once to ensure that licenses have been agreed to and all components are installed, you should open Xcode at least once before proceeding to the next step.

Install java. At the time of this writing, the latest version is [JDK 8u121](http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html).

Install [homebrew](https://brew.sh). If you favor another package manager, then you will need to modify the Makefile to reflect which package manager you are using.

Install [node.js](https://nodejs.org/dist/v6.9.5/node-v6.9.5.pkg). Latest stable version at the time of this writing is 6.9.5.

Install [Docker](https://download.docker.com/mac/stable/Docker.dmg).

Install [CocoaPods](https://cocoapods.org): ```sudo gem install cocoapods```.

Install [Fastlane](https://fastlane.tools): ```brew cask install fastlane```.

## Install your favorite IDEs

These are optional, but you really could benefit from not using TextEdit for writing code.

Install your favorite [Java IDE](https://www.jetbrains.com/idea/download/download-thanks.html?platform=mac&code=IIC). It could be [anything](http://jdee.sourceforge.net).

Install your favorite [node.js IDE](https://atom.io). Again, this could be [anything](https://emacsformacosx.com).

## Clone repositories

Now, it's time to start checking out some code!

Check out all the submodules of this repository:

```
$ git submodule update --init --recursive
```

## Build

Build everything. This could take a while.

```
$ make all
```

## Run

Before running the research UI you will need to configure the backend a bit, to get things up and running. To get things started, we need to get the Open mHealth server up and running, so we can load som configuration into it:

```
$ make run-omh
```

Next, connect to the postgres server and insert the needed configuration:

```
$ docker exec -ti omhdsuri_postgres_1 /usr/bin/env psql -U postgres
```

Now, insert a row with some client details. The client ids and secrets (```MY_RESEARCHER_CLIENT_SECRET_HERE```) should be replaced with something sensible.

```sql
\c omh
INSERT INTO oauth_client_details (
  client_id,
  client_secret,
  scope,
  resource_ids,
  authorized_grant_types,
  authorities
)
VALUES (
  'researcher-ui',
  'MY_RESEARCHER_CLIENT_SECRET_HERE',
  'read_data_points,read_surveys,write_surveys,delete_surveys',
  'dataPoints',
  'authorization_code,implicit,password,refresh_token',
  'ROLE_CLIENT'
);
```

Bare in mind that this secret is distributed to web clients, so it is important that the scope is limited.

Next, close the connection to the postgresql server and the docker instance (press ^D), to proceed.

Once the client has been configured on the server, we need to ensure that the ui has the same client configuration:

Create a file called ```app.config.json``` in the ```researcher-ui``` folder. The minimum configuration is as follows:

```json
{
  "clientAuth": "researcher-ui:MY_RESEARCHER_CLIENT_SECRET_HERE"
}
```

Once the client has been configured, all that is left is to run the client.

```
make run-ui
```

If you want to start everything with a single command (say, after a reboot), then simply ```make run```.

## Use

To start using the system, browse to [localhost:8000](http://localhost:8000/).

To build the iOS template application you need an Apple Developer Account. Once that is set up, run:

```
make ios-client
```
