package extension

import (
  "dagger.io/dagger/core"
)

#PullPgjwt: {
  pull: core.#GitPull & {
    remote: "https://github.com/michelp/pgjwt.git"
    ref: "master"
    keepGitDir: false
  }
  contents: pull.output
}