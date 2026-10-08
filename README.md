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
