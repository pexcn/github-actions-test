# github-actions-test

Environment variable | Default value | Description
---------------------|---------------|------------
`SMARTD_CONFIG` | `DEVICESCAN` | Configuration line in `/etc/smartd.conf`, only one line is supported
`SMTP_CONFIG` | `mail@example.com#user:pass@smtp.example.com:587` | SMTP client config, format: `<email>#<user>:<password>@<host>:<port>`
