# dirvish-cronjob

Dirvish cronjob for non-permanently available dirvish banks and branches


## Synopsis

Run `PREFIX/sbin/dirvish-cronjob` on permanently available branches once a day, invoked by `/etc/cron.daily/dirvish-cronjob`.  Output is directed to the logfile `/var/log/dirvish-cronjob.log`.

```sh
#!/bin/sh

# Run daily dirvish cronjob
[ -x dirvish-cronjob ] && dirvish-cronjob >> /var/log/dirvish-cronjob.log 2>&1
```

Run `PREFIX/sbin/dirvish-volatile` on volatile branches during specific hours of the day.  Backups will only be created if the dirvish branches are available, and a completed daily backup is not yet available.  Output is directory to the logfile `/var/log/dirvish-volatile.log`.

```config
# crontab fragment for dirvish-volatile

# run every 20 minutes between 9-21 hours daily
#
# min   hour   dom   mon   dow   user   command
*/20    9-21   *     *     *     root   dirvish-volatile >> /var/log/dirvish/volatile.log 2>&1
```


## Description

This project implements daily backups for non-permanently mounted dirvish banks and branches.


## Requirements

+ [dirvish](https://dirvish.org)


## Installation

Clone the remote repository and change into the local repository:

```console
$ git clone https://github.com/mboljen/dirvish-cronjob
$ cd dirvish-cronjob
```

Use the following command to install this software:

```console
$ make
$ make install
```

The default `PREFIX` is set to `/usr/local`.  In order to successfully complete the installation, you need to have write permissions for the installation location.


## Configuration

Specify remote clients in configuration file `/etc/dirvish/dirvish-volatile.conf`:

```config
[CLIENT1]
TYPE = HOST
SOURCE = 192.168.178.20
VAULT = someclient-root,someclient-home

[CLIENT2]
TYPE = HOST
SOURCE = 192.168.178.22
VAULT = otherclient-root,otherclient-home
```

+ For each client or device, specify a separate section.  Specify a unique section name, e.g. the name of the client or the device.
+ The parameter `TYPE` holds either the `HOST` or `DEVICE`.
+ The parameter `SOURCE` holds a comma-separated list of IP addresses (required for `TYPE=HOST` only)
+ The parameter `VAULT` holds a comma-separated list of dirvish vaults available for this client or device.


## Contributing

Pull requests are welcome.  For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.


## See also

+ [Remote backup with dirvish, rsync and ssh](http://apt-get.dk/howto/backup)


## License

[MIT](https://choosealicense.com/licenses/mit/)
