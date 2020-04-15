# Nagios check_3par

Basic support for monitoring HP 3PAR arrays by Nagios

## Usage
```
check_3par -h | -H <3PAR> [-d] [-u <username>] [-i <inform_cli> [-p <password_file>]] [-w <warning>] [-c <critical>] COMMAND [ arg [arg ...]]

Options:
    -h, --help 
                Print detailed help screen
    -H, --hostname=ADDRESS 
                3PAR controler
    -i, --inform-bin=PATH
                Path to 3PAR Inform CLI. Default connection method is SSH.
    -u, --username=USER
                3PAR username
    -p, --password-file=PATH
                Password file for 3PAR Inform CLI
    -w, --warning=TRESHOLD (default: 80)
                Warning treshold
    -c, --critical=TRESHOLD (default: 90)
                Critical treshold
    -d, --debug
                Turn on debugging
```

## Supported commands 
```

   check_pd :   Check status of physical disks
                   Degraded ->      Warning
                   Failed ->        Critical

   check_node :    Check status of controller nodes
                   Degraded ->      Warning
                   Failed ->        Critical

   check_ld :   Check status of logical disks
                   Degraded ->      Warning
                   Failed ->        Critical

   check_vv :   Check status of virtual volumes
                   Degraded ->      Warning
                   Failed ->        Critical

   check_port_fc : Check status of FC ports
                   loss_sync ->     Warning
                   config_wait ->   Warning
                   login_wait ->    Warning
                   non_participate ->   Warning
                   error ->         Critical

   check_cap_ssd : Check used SSD capacity
                   >= 80 ->         Warning
                   >= 90 ->         Critical

   check_cap_fc :   Check used FC capacity
                   >= 80 ->         Warning
                   >= 90 ->         Critical

   check_cap_nl : Check used NL capacity 
                   >= 80 ->         Warning
                   >= 90 ->         Critical

   check_ps_node : Check Power Supply Node
                   Degraded ->      Warning
                   Failed ->        Critical

   check_ps_cage : Check Power Supply Cage
                   Degraded ->      Warning
                   Failed ->        Critical

   check_volume <VOLUMENAME> : Check status of volume
                   Degraded ->      Warning
                   Failed ->        Critical

   check_qw <QWIP> : Check status of quorum witness
                   loss_sync ->     Critical
                   error ->         Critical
				   
   check_health :  Check overall state of the system
   
   check_alerts : Check status of system alerts
				   
```

## Usage in Nagios

Copy file `check_3par` to Nagios plugins directory (for example `/usr/lib/nagios/plugins/`).

Copy file `3par.cfg` to Nagios `conf.d` directory (for example `/etc/nagios/conf.d`).

Read `3par.cfg` and adjust it to your needs and restart nagios `service nagios restart`

## Testing

You can test `check_3par` while developing. Copy `test.sh.templ` to `test.sh`, edit it to meet your needs and enjoy happy testing ... ;-)

## Links

Nagios plugin developement [https://nagios-plugins.org/doc/guidelines.html#PLUGOPTIONS]
