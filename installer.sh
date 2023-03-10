#!/bin/sh
# ###########################################
echo " SCRIPT : DOWNLOAD AND INSTALL Channels "
TMPDIR='/tmp'
PACKAGE='astra-sm'
MY_URL='https://raw.githubusercontent.com/emilnabil/channel-ciefp/main'

########################
VERSION=$(wget $MY_URL/version -qO- | cut -d "=" -f2-)

########################
BINPATH=/usr/bin
ETCPATH=/etc
ASTRAPATH=${ETCPATH}/astra
######
BBCPMT=${BINPATH}/bbc_pmt_starter.sh
BBCPY=${BINPATH}/bbc_pmt_v6.py
BBCENIGMA=${BINPATH}/enigma2_pre_start.sh
######
SYSCONF=${ETCPATH}/sysctl.conf
ASTRACONF=${ASTRAPATH}/astra.conf
ABERTISBIN=${ASTRAPATH}/scripts/abertis

########################
CONFIGpmttmp=${TMPDIR}/bbc_pmt_v6/bbc_pmt_starter.sh
CONFIGpytmp=${TMPDIR}/bbc_pmt_v6/bbc_pmt_v6.py
CONFIGentmp=${TMPDIR}/bbc_pmt_v6/enigma2_pre_start.sh
CONFIGsysctltmp=${TMPDIR}/${PACKAGE}/sysctl.conf
CONFIGastratmp=${TMPDIR}/${PACKAGE}/astra.conf
CONFIGabertistmp=${TMPDIR}/${PACKAGE}/abertis

########################
if [ -f /etc/opkg/opkg.conf ]; then
    STATUS='/var/lib/opkg/status'
    OSTYPE='Opensource'
    OPKG='opkg update'
    OPKGINSTAL='opkg install'
fi

########################
rm -rf /etc/enigma2/lamedb
rm -rf /etc/enigma2/*list
rm -rf /etc/enigma2/*.tv
rm -rf /etc/enigma2/*.radio
rm -rf /etc/tuxbox/*.xml

########################
install() {
    if grep -qs "Package: $1" $STATUS; then
        echo
    else
        $OPKG >/dev/null 2>&1
        echo "   >>>>   Need to install $1   <<<<"
        echo
        $OPKGINSTAL "$1"
        sleep 1
        clear
    fi
}

########################
if [ $OSTYPE = "Opensource" ]; then
    for i in dvbsnoop $PACKAGE; do
        install $i
    done
fi

#########################
case $(uname -m) in
armv7l*) plarform="arm" ;;
mips*) plarform="mips" ;;
esac

#########################
rm -rf ${ASTRACONF} ${SYSCONF}
#########################
echo
set -e
echo "Downloading And Insalling Channel Please Wait ......"
wget $MY_URL/channels_backup_by-ciefp-motor.tar.gz -qP $TMPDIR
tar -xzf $TMPDIR/channels_backup_by-ciefp-motor.tar.gz -C /
sleep 5
set +e
echo ""
sleep 2
echo ""
#########################
if [ -f $BBCPMT ] && [ -f $BBCPY ] && [ -f $BBCENIGMA ]; then
    echo "   >>>>   All Config BBC Files found   <<<<"
    sleep 2
else
    set -e
    echo "Downloading And Insallling Config BBC Please Wait ......"
    wget $MY_URL/bbc_pmt_v6.tar.gz -qP $TMPDIR
    tar -xzf $TMPDIR/bbc_pmt_v6.tar.gz -C $TMPDIR
    set +e
    chmod -R 755 ${TMPDIR}/bbc_pmt_v6
    sleep 1
    echo "---------------------------------------------"
   
    echo "---------------------------------------------"
fi

#########################
if [ $OSTYPE = "Opensource" ]; then
    if [ -f $ASTRACONF ] && [ -f $ABERTISBIN ] && [ -f $SYSCONF ]; then
        echo "   >>>>   All Config $PACKAGE Files found   <<<<"
        sleep 2
    else
        set -e
        echo "Downloading Config $PACKAGE Please Wait ......"
        wget $MY_URL/astra-"${plarform}".tar.gz -qP $TMPDIR
        tar -xzf $TMPDIR/astra-"${plarform}".tar.gz -C $TMPDIR
        set +e
        chmod -R 755 ${TMPDIR}/${PACKAGE}
        sleep 1
        echo "---------------------------------------------"
        if [ ! -f $SYSCONF ]; then
            cp -f $CONFIGsysctltmp $ETCPATH >/dev/null 2>&1
            echo "[send (sysctl.conf) file]"
        fi
        if [ ! -f $ASTRACONF ]; then
            cp -f $CONFIGastratmp $ASTRAPATH >/dev/null 2>&1
            echo "[send (astra.conf) file]"
        fi
        if [ ! -f $ABERTISBIN ]; then
            cp -f $CONFIGabertistmp $ASTRAPATH/scripts >/dev/null 2>&1
            echo "[send (abertis) file]"
        fi
        echo "---------------------------------------------"
    fi
fi

#########################
rm -rf ${TMPDIR}/channels_backup_by-ciefp-motor.tar.gz
rm -rf ${TMPDIR}/* astra-
rm -rf ${TMPDIR}/* bbc_pmt_v6

sync
echo ""
echo ""
echo "*********************************************************"
echo "#       Channel And Config INSTALLED SUCCESSFULLY       #"
echo "   UPLOADED BY  >>>>   EMIL_NABIL "   
sleep 4;
	echo '========================================================================================================================='
echo "#                    ${VERSION}                         #"                 
echo "*********************************************************"
echo "#           your Device will RESTART Now                #"
echo "*********************************************************"
sleep 2

if [ $OSTYPE = "Opensource" ]; then
    init 6
else
    systemctl restart enigma2
fi

exit 0




