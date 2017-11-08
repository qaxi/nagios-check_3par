# ToDo

## Verbose output
 -v, --verbose
 0 Single line, minimal output. Summary 
 1 Single line, additional information (eg list processes that fail) 
 2 Multi line, configuration debug output (eg ps command used) 
 3 Lots of detail for plugin problem diagnosis

## adjust output for diagnosis 
plugin should print the diagnostic and just the usage part of the help message. A well written plugin would then have --help as a way to get the verbose help.

## repair output and return values
0 OK The plugin was able to check the service and it appeared to be functioning properly

1 Warning The plugin was able to check the service, but it appeared to be above some "warning" threshold or did not appear to be working properly

2 Critical The plugin detected that either the service was not running or it was above some "critical" threshold

3 Unknown Invalid command line arguments were supplied to the plugin or low-level failures internal to the plugin (such as unable to fork, or open a tcp socket) that prevent it from performing the specified operation. Higher-level errors (such as name resolution errors, socket timeouts, etc) are outside of the control of plugins and should generally NOT be reported as UNKNOWN states.

## Add support for snapshots
showvv -notree -nohdtot | grep vcopy
