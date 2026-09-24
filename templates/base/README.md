# {{ .project_name }}{{ if .project_description }}

{{ .project_description }}{{ end }}

## Development

This project uses [mise](https://mise.jdx.dev) to manage tool versions and tasks, and [prek](https://prek.j178.dev) for
git hooks.

```bash
mise tasks                  # list all available tasks
mise run lint               # run all linters via prek
mise run format             # format the repository
mise run update-deps        # diff pinned dependency updates (add --apply to open PRs)
mise run release            # bump the version with cog and publish a GitHub release
```
{{- if .devcontainer }}

### Using the devcontainer

Open this project in VS Code and "Reopen in Container" to get a fully configured environment.
{{- end }}
