#!/bin/sh

. ../../../prepare.inc.sh
. ../../../toolbox.inc.sh


# ---- do the actual testing ----

result=PASS
echo "++++ BEGINNING TEST" >$OUTPUTFILE

# check that an empty key type fails correctly
marker "CHECK EMPTY KEY TYPE"
create_key --fail "" wibble stuff @p
expect_error EINVAL

# check that an unsupported key type fails correctly
marker "CHECK UNSUPPORTED KEY TYPE"
create_key --fail lizardsgizzards wibble stuff @p
expect_error ENODEV

# check that an invalid key type fails correctly
marker "CHECK INVALID KEY TYPE"
create_key --fail .user wibble stuff @p
expect_error EPERM

# check that an maximum length invalid key type fails correctly
marker "CHECK MAXLEN KEY TYPE"
create_key --fail $maxtype wibble stuff @p
expect_error ENODEV

# check that an overlong key type fails correctly
marker "CHECK OVERLONG KEY TYPE"
create_key --fail a$maxtype wibble stuff @p
expect_error EINVAL

# check that creation of a keyring with non-empty payload fails correctly
marker "CHECK ADD KEYRING WITH PAYLOAD"
create_key --fail keyring wibble a @p
expect_error EINVAL

# check that an max length key description works correctly (PAGE_SIZE inc NUL)
if [ $PAGE_SIZE -lt $maxsquota ]
then
    marker "CHECK MAXLEN DESC"
    create_key user $maxdesc stuff @p
    expect_keyid keyid
else
    marker "CHECK MAXLEN DESC FAILS WITH EDQUOT"
    create_key --fail user $maxdesc stuff @p
    expect_error EDQUOT
fi

# check that an overlong key description fails correctly (>4095 inc NUL)
marker "CHECK OVERLONG DESC"
create_key --fail user a$maxdesc stuff @p

expect_error EINVAL

# check that a bad key ID fails correctly
marker "CHECK BAD KEY ID"
create_key --fail user wibble stuff 0
expect_error EINVAL

echo "++++ FINISHED TEST: $result" >>$OUTPUTFILE

# --- then report the results in the database ---
toolbox_report_result $TEST $result