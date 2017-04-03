# Nagios check_3par

Basic support for monitoring HP 3PAR arrays by Nagios

Unfortunately this plugin does not conform to Nagios plugin commandline standard

## Usage
```
check_3par 3PAR Username Command
```

## Supported commands 
```
    check_pd :     Check status of physical disks
        Degraded ->        Warning
        Failed ->      Critical

    check_node :    Check status of controller nodes
        Degraded ->    Warning
        Failed ->          Critical

    check_ld : Check status of logical disks
        Degraded ->        Warning
        Failed ->          Critical

    check_vv :     Check status of virtual volumes
        Degraded ->        Warning
        Failed ->          Critical

    check_port_fc : Check status of FC ports
        loss_sync ->   Warning
        config_wait -> Warning
        login_wait ->  Warning
        non_participate -> Warning
        error ->       Critical

    check_cap_ssd : Check used SSD capacity
        >= $PCWARNINGSSD ->     Warning
        >= $PCCRITICALSSD ->    Critical

    check_cap_fc :     Check used FC capacity
        >= $PCWARNINGFC ->         Warning
        >= $PCCRITICALFC ->     Critical

    check_cap_nl : Check used NL capacity 
        >= $PCWARNINGNL ->      Warning
        >= $PCCRITICALNL ->     Critical

    check_ps_node : Check Power Supply Node
        Degraded -> Warning
        Failed ->   Critical

    check_ps_cage : Check Power Supply Cage
        Degraded -> Warning
        Failed ->   Critical

    check_qw : Check status of quorum witness
        loss_sync ->   Critical
        error ->       Critical
```
