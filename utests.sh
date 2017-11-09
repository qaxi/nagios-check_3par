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
    EXPRET=$1
    shift
    case "$EXPRET" in 
        OK   ) RET=0 ;; 
        WARN ) RET=1 ;; 
        CRIT ) RET=2 ;; 
        UNKN ) RET=3 ;; 
	*   ) echo "Wrong parameter for utest()" >&2; exit 128 ;; 
    esac


    CMDOUT=$( $CMD $@ )
    CMDRET=$?
   
    if [ $CMDRET -eq $RET ]
    then
        echo "### OK # \$CMD $@"
    else
        echo 
        echo "############################################"
        echo "# Failed $CMD $@"
        echo "# Expected return '$RET' but get '$CMDRET'."
        echo "##########"
        echo "$CMDOUT"
        echo "############################################"
        echo 
    fi
}

echo "####################################"
echo "### Runing check_node tests"  
echo "### CMD: $CMD"
echo
echo " !!! Warning !!!"
echo " If tested 3PAR array is in an edgy condition,"
echo " you can get false negatives/positives"
echo 
utest OK check_node
utest OK check_pd 
utest OK check_ld
utest OK check_vv
utest OK check_ps_node
utest OK check_ps_cage

utest OK check_cap_ssd
# check Warning level
utest WARN -w 1 -c 99 check_cap_ssd
utest OK -w 98 -c 99 check_cap_ssd
# check Critical level
utest CRIT -w 1 -c 2 check_cap_ssd
utest OK -w 98 -c 99 check_cap_ssd

utest OK check_cap_fc
# check Warning level
utest WARN -w 1 -c 99 check_cap_fc
utest OK -w 98 -c 99 check_cap_fc
# check Critical level
utest CRIT -w 1 -c 2 check_cap_fc
utest OK -w 98 -c 99 check_cap_fc

utest OK check_cap_nl
# check Warning level
utest WARN -w 1 -c 99 check_cap_nl
utest OK -w 98 -c 99 check_cap_nl
# check Critical level
utest CRIT -w 1 -c 2 check_cap_nl
utest OK -w 98 -c 99 check_cap_nl

utest OK check_volume $VOL
# check Warning level
utest WARN -w 1 -c 99 check_volume $VOL
utest OK -w 98 -c 99 check_volume $VOL
# check Critical level
utest CRIT -w 1 -c 2 check_volume $VOL
utest OK -w 98 -c 99 check_volume $VOL

# check real QW
utest OK check_qw $QW
# check nonexitsting QW
utest UNKN check_qw 8.8.8.8

utest OK check_alerts
utest OK check_health


# vim: tabstop=4 softtabstop=4 shiftwidth=4 expandtab:
