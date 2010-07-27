#!/bin/bash

rm -f print.pdf >/dev/null 2>/dev/null

QTVERSION=`qmake --version | tail -n1| cut -d' ' -f4`
TESTNAME=$(basename `pwd`)
PASSED=0
FAILED=0
SKIPPED=0

function pass # test_name
{
    echo "PASS   : ${TESTNAME}::$1()"    
    PASSED=$((PASSED+1))
}

function fail # test_name
{
    echo "FAIL!  : ${TESTNAME}::$1()"    
    FAILED=$((FAILED+1))
}

function output # test_name text
{
    echo -n "QDEBUG : ${TESTNAME}::$1() "
    shift
    echo $@
}

function run_command # test_name command
{
    test=$1
    shift
    command=$@
    output=$($command 2>&1)
    returned=$?
    ORIGIFS=$IFS
    IFS=`echo -en "\n\b"`
    for line in $output
    do
        output $test $line
    done
    IFS=$ORIGIFS
    [ $returned -eq 0 ] && pass $test || fail $test
}


echo "********* Start testing of ${TESTNAME} *********"
echo "Config: Using QTest library ${QTVERSION}, Qt ${QTVERSION}"
pass "initTestCase"

# -------- actual testing goes here --------

run_command "runPrinting" "../../fwbuilder -f test.fwb -P test"
run_command "fileExists" "ls print.pdf"

# --------- end of actual testing ---------

rm -f print.pdf >/dev/null 2>&1

pass "cleanupTestCase"
echo "Totals: ${PASSED} passed, ${FAILED} failed, ${SKIPPED} skipped"
echo "********* Finished testing of ${TESTNAME} *********"
[ ${FAILED} -eq 0 ] && exit 0 || exit 1
