#!/bin/bash
set -e
mkdir -p $1
#for i in bmath-test75-worker01 bmath-test75-worker02 bmath-test75-worker03 bmath-test75-worker04
for i in @nodes@
do
        name=`echo $i | sed "s/-//g"`
        exists=`kubectl exec $name -- ls -ltr /mnt | grep -w $1 | wc -l`
        if [ $exists -eq 1 ]
        then
                kubectl exec $name -- tar -zcf $1.tar.gz /mnt/$1
                kubectl cp $name:/$1.tar.gz ./$1/$name.tar.gz
                kubectl exec $name -- rm $1.tar.gz
                kubectl exec $name -- rm -rf /mnt/$1
        fi
done
cd $1
#for i in bmath-test75-worker01 bmath-test75-worker02 bmath-test75-worker03 bmath-test75-worker04
for i in @nodes@
do
        name=`echo $i | sed "s/-//g"`
        exists=`ls -ltr | grep $name | wc -l`
        if [ $exists -eq 1 ]
        then
                tar -zxf $name.tar.gz
        fi
done
cd mnt/$1
grep -w IOPS fio*
grep -w lat fio* | grep -i min
