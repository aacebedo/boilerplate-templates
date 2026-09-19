# boilerplate-templates

[Boilerplate](https://boilerplate.gruntwork.io) templates that stack on top of each other to scaffold a project's
tooling: `base`, plus the `container`, `hugo`, `python` and `rust` layers.

## Layout

- `templates/base/` is the entry point you always apply. It renders the base tooling, then every layer listed in its
  `layers` variable, in that order, as a Boilerplate dependency. Layers inherit all the base variables.
- `templates/<layer>/` holds a layer's own files and its `boilerplate.yml`. A layer never edits base files itself: what
  it adds to them (hooks in `prek.toml`, ignores in `.gitignore`, words in `.codebook.toml`, keys in `.biome.json`, job
  options and steps in `pr.yaml`) lives in `templates/<layer>/fragments/<name>`. The base files include those fragments
  through the `fragments` partial in `templates/base/_partials/fragments.tmpl`.
- Every task script under `.mise/tasks/` sources `.mise/lib/task.sh`, which the base layer owns. Running a script
  directly re-runs it through `mise run`, so its tools, environment, dependencies and usage flags always apply.

Every file is a Go template. Files meant for another templating engine (updatecli manifests, mise `{{vars.*}}`, Hugo
layouts) are wrapped in a raw string: ``{{`...`}}``.

## Usage

### Apply just `base`

```bash
mkdir my-project && cd my-project
git init
boilerplate --output-folder . \
  --template-url 'git::https://github.com/aacebedo/boilerplate-templates.git//templates/base?ref=v0.1.0'
git add . && git commit -m 'Apply base template'
```

A hook writes `.boilerplate-answers.yaml` on the way out: every variable the templates resolved, flat, plus the
`template_ref` the project was generated from, read from the template checkout Boilerplate rendered. That file is what
the update and check tasks work from, so commit it. `template_ref` is the release tag when the templates were applied
from one and the bare commit otherwise, so both go straight back into a `?ref=`; pin `?ref=` to a release tag, because a
commit gives `check-templates` no release to compare against. The repository itself is not recorded: both tasks
hard-code `github.com/aacebedo/boilerplate-templates`, so a project applied from a fork or a local checkout still
updates from there.

Boilerplate only prompts for the variables that have no default or ask for confirmation; the tool versions silently take
their defaults. Pass `--var name=value` or `--var-file vars.yml` (and `--non-interactive`) to script it.

### Stack `base` + `rust` (or any other layers)

```bash
boilerplate --output-folder . \
  --template-url 'git::https://github.com/aacebedo/boilerplate-templates.git//templates/base?ref=v0.1.0' \
  --var 'layers=["rust"]'

mise install
mise run rust:build
mise run rust:run:tests

mise run lint
```

### Updating later

Boilerplate has no update command, so the base template ships one as a mise task: it renders the recorded version and
the latest release with the recorded variables, then 3-way merges the difference into the project, leaving conflict
markers where your changes and the template's overlap.

```bash
mise run check-templates    # is a newer release available?
mise run update-templates   # update to the latest release tag
```

The update always targets the latest release and never changes an answer, so it only ever carries what the templates
themselves changed. To add or drop a layer, edit `layers` in `.boilerplate-answers.yaml` and re-apply the template with
`--var-file .boilerplate-answers.yaml`. Both tasks read that file, and `update-templates` rewrites it with the answers
and the tag of the version it just rendered.

## Differences from the Copier version

- One entry point and one answers file instead of one `copier copy` and one answers file per template: the layers are
  applied, updated and removed through the `layers` variable.
- Layers contribute to base files through fragments rendered with the base files, instead of tasks that edit them after
  the fact, so updates are plain 3-way merges and never re-run edits.
- The LICENSE download and `.boilerplate-answers.yaml` are Boilerplate hooks, so they run on the first application only:
  updates render with `--no-hooks`, which keeps the answers file out of the 3-way merge, and `update-templates` rewrites
  it itself.
