module {{ .base_url | trimPrefixSprig "https://" | trimPrefixSprig "http://" | trimSuffixSprig "/" }}

go {{ .go_version }}
