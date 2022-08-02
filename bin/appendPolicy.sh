#!/bin/bash
# CONV_HOME is the location of conversion-data-mapper in system
# VAKTUN is policy id in EL (ie. 360000060202)
# TARGET_DIR is directory where new file is written in input
# SOURCE is the location of datafiles
    # by default it reads data from the input folder
    # but you can specify dataset if needed (ie. SELKO_1600_V3)

# Example commands
# ./selectPolicy.sh 360000060202
# ./selectPolicy.sh 360000060202 SELKO_1601_V4

CONV_HOME="$HOME/workspace/migrationtools/hv/conversion-data-mapper"
VAKTUN="${1}"
SOURCE="input/${2}"
TARGET_DIR="input/target"
#set -x
# create target dir
TARGET="${CONV_HOME}/${TARGET_DIR}"
if [ ! -d "${TARGET}" ]; then
	mkdir -p "${TARGET}"
fi

rm -v ${TARGET}/*

# POLICY DATA
echo "Write agreement data into files..."
# search vakuutus from all files expect those starting with 'SELKO'
cd ${CONV_HOME}
for ffile in ${SOURCE}/* ; do
    echo ${ffile##*/}
    targetDAT=${ffile##*/}
    grep -a ${VAKTUN} $ffile >> ${TARGET_DIR}/${targetDAT}
done


# CLIENT DATA
#set -x
cl=$( wc -l ${TARGET}/SELKO_SOP101002.DAT | awk '{ print $1 }' )
if [ $cl -gt 0 ]; then
	echo "Write client data into files..."
	for ffile in ${SOURCE}/SELKO_* ; do
		echo ${ffile##*/}
		targetDAT=${ffile##*/}
	    grep -a "$(( grep -a ${VAKTUN} ${SOURCE}/SELKO_SOP101002.DAT) | awk '{ print $4 }' )" $ffile >> ${TARGET}/${targetDAT}
	done
else
	echo "Write client data into files..."
	for ffile in ${SOURCE}/SELKO_* ; do
		if [ "$ffile" == "SELKO_ASI100002.DAT" ]; then
			:
		else
			echo ${ffile##*/}
			targetDAT=${ffile##*/}
			grep -a "$(( grep -a ${VAKTUN} ${SOURCE}/SELKO_ASI100002.DAT) | awk '{ print $4 }' )" $ffile >> ${TARGET}/${targetDAT}
		fi
	done
fi

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

