#!/bin/bash
#cd /home/yrjo/workspace/migrationtools/conversion-data-mapper/out
#rm -v *
cd /home/yrjo/workspace/migrationtools/conversion-data-mapper
rm data-mapper.log
mvn test -Dtest=RunPolicyConversionFromFolder | tee ../prevalidator/validator.log | tee test.log
sta=${PIPESTATUS[0]}
if [ $sta -eq 0 ]; then
	cd /home/yrjo/workspace/migrationtools/prevalidator/bin
	./PreValidator.sh | tee -a ../validator.log | tee -a /home/yrjo/workspace/migrationtools/conversion-data-mapper/test.log
	exit 0
else
	exit 1
fi

