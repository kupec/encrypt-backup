# Backup script #

The script creates gzipped tarball of the specified folder and encrypt it with symmetrical key. The process is done by pipes, therefore it is not necessary to have a disk space for intermediate results.

## Prepare configuration ##

Copy `config.inc.in` to `config.inc` and set custom values for variables

## Run ##

```
./make-backup.sh
```
