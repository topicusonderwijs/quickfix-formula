# About

This directory holds the minimal configuration to configure a primary / secondary hot standby setup.


This method is used for somtoday setting up a replica of a 3.1TB database under
1 hour (using 10Gbit/s link).

# Scenario
We asume there are 2 AlmaLinux 9 hosts:

  - pg1.virtualt00bz.lan as primary
  - pg2.virtualt00bz.lan as secondary

- On the host `pg1.virtualt00bz.lan` the tcp port 5432 is accessible from the host `pg2.virtualt00bz.lan`.
- Both hosts are located in the subnet `10.255.0.0/16`.

## Primary pillar
```yaml
postgresql:
  instance:
    primary:
      version: 16
      initdb_params:
        encoding: UTF8
      databases:
        - name: yolodb
      pg_hba:
        - type: host
          database: replication
          user: replicator
          address: 10.255.0.0/16
          method: scram-sha-256
      settings:
        listen_addresses: '*'
        wal_level: hot_standby      # Required to enable replication, needs restart if changed on existing instance.
      roles:
        - name: replicator
          login: True
          replication: True         # Required to give the role "replicator" replication rights. 
          encrypted: scram-sha-256  # If set to True md5 is used.
          password: banaan
```

## Secondary pillar
```
postgresql:
  instance:
    hotstandby:
      version: 16               # Note: Versions __must__ be the same on primary and secondary.
      is_standby: True          # Here we indicate that we want to configure this instance as a standby.
      standby_config:           # Here we define the connection details to the primary instance.
        remote_host: pg1.virtualt00bz.lan
        remote_port: 5432
        remote_user: replicator
        remote_password: banaan
```

## Conslusion

Here we have shown how we can configure a primary/secondary postgresql setup using this formula.
Note that this is a absolute minimal configuration. Additional configuration can be done on the
primary as well as on the hotstandby.
