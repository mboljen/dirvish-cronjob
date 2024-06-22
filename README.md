# dirvish-cronjob

Dirvish cronjob for non-permanent available dirvish banks and branches


## Description

This cronjob implements daily backups for non-permanently mounted dirvish banks and branches.


## Synopsis

None.


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

Run `dirvish` on permanently available branches once a day, invoked by `PREFIX/etc/cron.daily/dirvish-cronjob`:

```sh
#!/bin/sh

# Run daily dirvish cronjob
[ -x dirvish-cronjob ] && dirvish-cronjob >> /var/log/dirvish-cronjob.log 2>&1
```

Run `dirvish` on volatile branches during specific hours of the day every 20 minutes until completed successfully:

```config
# crontab fragment for dirvish-volatile

# run every 20 minutes between 9-21 hours daily
#
# min   hour   dom   mon   dow   user   command
*/20    9-21   *     *     *     root   dirvish-volatile >> /var/log/dirvish/volatile.log 2>&1
```

Specify remote clients in configuration file `PREFIX/etc/cron.d/dirvish-volatile`:


```config
[Client1]
TYPE = HOST
SOURCE = 192.168.178.20
VAULT = someclient-root,someclient-home

[Client2]
TYPE = HOST
SOURCE = 192.168.178.22
VAULT = otherclient-root,otherclient-home
```


## Contributing

Pull requests are welcome.  For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.


## License

[MIT](https://choosealicense.com/licenses/mit/)
