# postgresql-formula

An idempotent saltformula to install and configure postgresql on CentOS7 hosts.


## Available states

### `postgresql`

This will run the following steps for each defined instance (see `pillar.example`):

  * Configure upstream postgresql yum repositories.
  * Install postgresql12-{server,contrib} (Version can be changed from pillar)
  * Perform an `initdb` in `/var/lib/pgsql/<version>/<instance_name>` OR perform a pgbasebackup in case of a hot\_standby \(see [example](examples/hot_standby/readme.md)\)
  * Configure the `pg_hba.conf` file. (This file can be changed from pillar as well as locally on the server.)
  * Add an include to `postgresql.conf` for the file `postgresql.conf.saltstack` 
  * Add all requested configuration from pillar in `postgresql.conf.saltstack`
  * Start the postgresql if it is not running (it will NOT be automatically restarted on config changes).
  * Reload postgresql config if there are config changes
  * Configure roles, databases and extensions.

#### Notes
  * The service will not be restarted on config changes when needed. So after changing for example the portnumber expect the state run to fail because psql will not be able to connect to the new port.
  * This formula will only initialize on the location `/var/lib/pgsql/<version>/<instance_name>`
  * This formula will not perform updates. 
  * This formula is idempotent an can always be run safely.
  * A version must be explicitly set in the pillar, this to prevent unwanted software upgrades during formula updates

### `postgresql.pgbackrest`

This will install and configure pgbackrest. Optionally cronjobs can be configured. 
See the following sections in `pillar.example`:

- `postgresql.instance.artifactory_test.pgbackrest` 
- `postgresql.pgbackrest`

## Example
See `pillar.example` for all configuration options

## Common configuration:

### Roles

#### Monitoring user
```
postgresql:
  instance:
    mydb:
      roles:
        - name: monitoring
          login: True
          encrypted: scram-sha-256
          groups: pg_monitor
          password: s3cr3t
```

#### Replication user
```
postgresql:
  instance:
    mydb:
      roles:
        - name: repl
          login: True
          replication: True
          encrypted: scram-sha-256
          password: s3cr3t
      pg_hba:
        - type: host
          database: replication
          user: repl
          address: 10.255.0.0/24
          method: md5
```
#### Super user
```
postgresql:
  instance:
    mydb:
      roles:
        - name: admin
          login: True
          superuser: True
          encrypted: scram-sha-256
          password: s3cr3t
```
