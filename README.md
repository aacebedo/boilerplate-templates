# boilerplate-templates

[Boilerplate](https://boilerplate.gruntwork.io) templates that stack on top of each other.

The tool versions live in `static/mise/config`, which the generated projects pull in with mise's
[`include`](https://mise.jdx.dev/configuration.html#include) rather than copying them, so they need mise 2026.10.6 or
later.

## Usage

### Apply just `base`

```bash
mkdir my-project && cd my-project
git init
boilerplate --output-folder . \
  --template-url 'git::https://github.com/aacebedo/boilerplate-templates.git//templates/base?ref=main'
git add . && git commit -m 'Apply base template'
```

### Updating later

Boilerplate has no update command, so the base template ships one as a mise task.

```bash
mise run check-templates
mise run update-templates
```

## Development

This project uses [mise](https://mise.jdx.dev) to manage tool versions and tasks, and [prek](https://prek.j178.dev) for
git hooks. The tool versions come from the templates through mise's
[`include`](https://mise.jdx.dev/configuration.html#include), which needs mise 2026.10.6 or later.

```bash
mise tasks                  # list all available tasks
mise run lint               # run all linters via prek
mise run format             # format the repository
mise run update-deps        # diff pinned dependency updates (add --apply to open PRs)
mise run release            # bump the version with cog and publish a GitHub release
```

### Using the devcontainer

Open this project in VS Code and "Reopen in Container" to get a fully configured environment.
