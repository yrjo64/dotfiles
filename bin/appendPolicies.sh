#!/bin/bash
#
# CONV_HOME is the location of conversion-data-mapper in system
# TARGET_DIR is directory where new file is written in input
# SOURCE is the location of datafiles
    # by default it reads data from the input folder
    # but you can specify dataset if needed (ie. SELKO_1600_V3)

# Example commands
# ./selectPolicies.sh vakTunList.txt
# ./selectPolicy.sh vakTunList.txt SELKO_1601_V4
#
# parameter 1 : list of policynumbers, one per line
# parameter 2 : input dir (optional)

CONV_HOME="$HOME/workspace/migrationtools/conversion-data-mapper"
VAKTUNLIST="${1}"
SOURCE="input/${2}"
TARGET_DIR="input/target"

# create target dir
TARGET="${CONV_HOME}/${TARGET_DIR}"
if [ ! -d "${TARGET}" ]; then
	mkdir -p "${TARGET}"
fi

# clean target
echo "Clean ${TARGET_DIR}"
rm -v ${TARGET_DIR}/*

# POLICY DATA
echo "Write agreement data into files..."
# search vakuutus from all files expect those starting with 'SELKO'
cd ${CONV_HOME}
for ffile in ${SOURCE}/* ; do
    echo ${ffile##*/}
    targetDAT=${ffile##*/}
    while IFS= read -r VAKTUN; do 
        echo -n "${VAKTUN} "
        grep -a ${VAKTUN} $ffile >> ${TARGET_DIR}/${targetDAT}
    done < ${VAKTUNLIST}
    echo
done

# CLIENT DATA
# SELKO_TUOT_1602_V2 is broken must use awk '{ print $3 }' instead of awk '{ print $4 }'
echo "Write client data into files..."
#set -x
cl=$( wc -l ${TARGET}/SELKO_SOP101002.DAT | awk '{ print $1 }' )
if [ $cl -gt 0 ]; then
    SOURCE_ASI=SELKO_SOP101002.DAT
    COL=4
else
    SOURCE_ASI=SELKO_ASI100002.DAT
    COL=3
fi

for ffile in ${SOURCE}/SELKO_* ; do
    echo ${ffile##*/}
    targetDAT=${ffile##*/}
    while IFS= read -r VAKTUN; do 
        echo -n "${VAKTUN} "
	if [ $COL == 4 ]; then
            hunts=$(( grep -a ${VAKTUN} ${SOURCE}/${SOURCE_ASI} ) | awk '{ print $4 }' | sort -u )
            if [ -n "$hunts" ]; then
                for hunt in $hunts; do
                    grep -a "$hunt" $ffile >> ${TARGET}/${targetDAT}
                done
            fi
        else
            hunts=$(( grep -a ${VAKTUN} ${SOURCE}/${SOURCE_ASI} ) | awk '{ print $3 }' | sort -u )
            if [ -n "$hunts" ]; then
                for hunt in $hunts; do
                    grep -a "$hunt" $ffile >> ${TARGET}/${targetDAT}
                done
            fi
        fi
    done < ${VAKTUNLIST}
    echo
#read
done



# SORTING DATA AND REMOVING DUPLICATES
echo "Sorting data..."
# sort all .csv-files according to VAKTUN
for ffile in ${TARGET_DIR}/* ; do
    targetFile=${ffile##*/}
    sort $ffile -u -o ${TARGET}/${targetFile}
done

# sort client data
cd ${CONV_HOME}
# sort SELKO_ASI-files according to HETU/YTUNNUS remove duplicates
for ffile in ${TARGET_DIR}/SELKO_ASI* ; do
    targetFile=${ffile##*/}
    sort --key=1.71 $ffile -o ${TARGET}/${targetFile}
done
# sort SELKO_SOP-file according to HETU/YTUNNUS and remove duplicates
for ffile in ${TARGET_DIR}/SELKO_SOP* ; do
    targetFile=${ffile##*/}
    sort --key=1.91 $ffile -o ${TARGET}/${targetFile}
done
echo "Done"
