module {{ .base_url | trimPrefixSprig "https://" | trimPrefixSprig "http://" | trimSuffixSprig "/" }}

go 1.27.1
