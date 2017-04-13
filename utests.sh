#!/bin/bash

CAPWARN=80  # warning at 80% of used disc capacity
CAPCRIT=90  # warnint at 90% of user disc capacity

PRGNAME=$(basename "$0")

DBG="n"
function dbg() { [ "$DBG" = "y" ] && echo "DBG: $*" >&2 ; }

OPTS=':hH:i:u:p:w:c:d-:'   # first : and lsast - is mandatory
function usage() {
[ -n "$*" ] && {
    exec 1>&2   # redirect STDOUT to STDERR for rest of script
    echo "${PRGNAME} ERROR: $*"
    echo ""
}

echo "Tests for check_3par.
Copyright (c) 2010-2017 various developers - look in source code

Usage: ${PRGNAME} -h | -H <3PAR> [-d] [-u <username>] [-i <inform_cli> [-p <password_file>]] [-w <warning>] [-c <critical>] <volumename> <quorum_witeness>

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

"
exit 128

}

[ "$#" = 0 ] &&  usage "Too few arguments."

while getopts "$OPTS" OPTION ; do
    dbg "option $OPTION optind $OPTIND optarg $OPTARG"
    case "$OPTION" in
        d  ) DBG="y";;
        h  ) usage ;;   
        H  ) INSERV="$OPTARG" ;;
        i  ) INFORMBIN="$OPTARG" ;;
        u  ) USERNAME="$OPTARG" ;;
        p  ) PASSFILE="$OPTARG" ;;
        w  ) CAPWARN="$OPTARG" ;;
        c  ) CAPCRIT="$OPTARG" ;;
        -  ) [ $OPTIND -ge 1 ] && optind=$(expr $OPTIND - 1 ) || optind=$OPTIND
            eval OPTION="\$$optind"
            OPTARG=$(echo $OPTION | cut -d'=' -f2)
            OPTION=$(echo $OPTION | cut -d'=' -f1)
            dbg "- option $OPTION optind $OPTIND optarg $OPTARG"
            case $OPTION in
                --debug )           DBG="y" ;;
                --help )            usage ;;
                --hostname )        INSERV="$OPTARG" ;;
                --inform-bin )      INFORMBIN="$OPTARG" ;;
                --username )        USERNAME="$OPTARG" ;;
                --password-file )   USERNAME="$OPTARG" ;;
                --warning )         CAPWARN="$OPTARG" ;;
                --critical )        CAPCRIT="$OPTARG" ;;
                ?  )  usage "Invalid option '$OPTARG'" ;;
                *  )  usage "parsing options failed";;
            esac
            #OPTIND=1
            #shift
            ;;
        ?  )  usage "Invalid option '$OPTARG'"  ;;
        *  )  usage "parsing options failed";;
    esac
done

shift $((OPTIND-1))

VOL="$1"
QW="$2"
TMPOUT=""

if [ "$DBG" = "y" ]
then
    DBG="-d"
else
    DBG=""
fi

if [ ! -x "./check_3par" ]
then
    usage "Can not run ./check_3par ."
fi

# CLI or SSH
if [ -n "$INFORMBIN" ]
then
    # To connect using the 3PAR CLI, use option -i and -p to setup the command 
    CMD="./check_3par -H $INSERV -i $INFORMBIN -p $PASSFILE -w $CAPWARN -c $CAPCRIT $DBG"
    # Note : connecting using the CLI requires creating password files (.pwf)
else
    # To connect using SSH use -u option to set username
    # Note : connecting using SSH requires setting public key authentication
    CMD="./check_3par -H $INSERV -u $USERNAME -w $CAPWARN -c $CAPCRIT $DBG"
fi

function utest() {
    
    echo "####################################"
    echo "# Test: \$CMD $@"
    $CMD $@
    echo
}

echo "####################################"
echo "### Runing check_node tests"  
echo "### CMD: $CMD"
echo
echo " !!! Warning !!!"
echo " If tested 3PAR array is in an edgy condition,"
echo " you can get false negatives/positives"
echo 
utest check_node
utest check_pd 
utest check_ld
utest check_vv
utest check_cap_ssd
utest -w 1 -c 2 check_cap_ssd
utest -w 98 -c 99 check_cap_ssd
utest check_cap_fc
utest -w 1 -c 2 check_cap_fc
utest -w 98 -c 99 check_cap_fc
utest check_cap_nl
utest -w 1 -c 2 check_cap_nl
utest -w 98 -c 99 check_cap_nl
utest check_ps_node
utest check_ps_cage
utest check_volume $VOL
utest -w 1 -c 2 check_volume $VOL
utest -w 98 -c 99 check_volume $VOL
utest check_qw $QW

# vim: tabstop=4 softtabstop=4 shiftwidth=4 expandtab:
