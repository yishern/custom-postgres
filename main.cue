package main

import (
    "dagger.io/dagger"
    "dagger.io/dagger/core"
    "universe.dagger.io/docker/cli"
    "universe.dagger.io/docker"
    "fiction.dev/postgres"
)

#ReadVersion: {
  dir: dagger.#FS

  read: core.#ReadFile & {
    input: dir
    path: "fiction_postgres_version.txt"
  }

  version: read.contents
}

dagger.#Plan & {
    actions: {
      _postgres: postgres.#PostgresBuild & {
        config: client.filesystem."./postgres_config".read.contents
      }
      _readVersion: #ReadVersion & {
        dir: client.filesystem.".".read.contents
      }

      // Run DB locally
      dev: cli.#Load & {
        image: _postgres.build.output
        host: client.network."unix:///var/run/docker.sock".connect
        tag: "fiction/postgres"
      }
      // Push Postgres to Docker Hub
      deploy: {
        versionRelease: docker.#Push & {
          "image": _postgres.build.output
          dest: "\(client.env.DOCKER_USERNAME)/postgres:\(_readVersion.version)"
          auth: {
            username: client.env.DOCKER_USERNAME
            secret: client.env.DOCKER_ACCESS_TOKEN
          }
        }
        latestRelease: docker.#Push & {
          "image": _postgres.build.output
          dest: "\(client.env.DOCKER_USERNAME)/postgres:latest"
          auth: {
            username: client.env.DOCKER_USERNAME
            secret: client.env.DOCKER_ACCESS_TOKEN
          }
        }
      }
    }
    client: {
      network: "unix:///var/run/docker.sock": connect: dagger.#Socket
      env: {
        DOCKER_USERNAME: string
        DOCKER_ACCESS_TOKEN: dagger.#Secret
      }
      // filesystem: '.' : {
      //   read: contents: dagger.#FS
      // }
      filesystem: {
        '.' : {
          read: contents: dagger.#FS
        }
        './postgres_config': {
          read: contents: dagger.#FS
        }
      }
    }
}