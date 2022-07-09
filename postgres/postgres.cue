package postgres

import (
  "dagger.io/dagger"
  "universe.dagger.io/docker"
  "fiction.dev/extension"
)

#PostgresBuild: {
  config: dagger.#FS
  pgjwt: extension.#PullPgjwt

  build: docker.#Build & {
    steps: [
      docker.#Pull & {
        source: "postgres:14"
      },
      docker.#Copy & {
        contents: config
        dest: "/etc/postgresql"
      },
      docker.#Run & {
        entrypoint: []
        command: {
          name: "apt-get"
          args: ["update"]
        }
      },
      docker.#Run & {
        entrypoint: []
        command: {
          name: "apt-get"
          args: ["install", "make", "git", "postgresql-server-dev-14", "postgresql-14-pgtap"]
          flags: {
            "-y": true
          }
        }
      },
      docker.#Run & {
        entrypoint: []
        command: {
          name: "mkdir",
          args:["/pgjwt"]
        }
      },
      docker.#Set & {
        config: {
          workdir: "/pgjwt"
        }
      },
      docker.#Copy & {
        contents: pgjwt.contents
      },
      docker.#Run & {
        entrypoint: []
        command: {
          name: "make"
        }
      },
      docker.#Run & {
        entrypoint: []
        command: {
          name: "make"
          args: ["install"]
        }
      },
      docker.#Set & {
        config: {
          workdir: "/"
        }
      } 
    ]
  }
}