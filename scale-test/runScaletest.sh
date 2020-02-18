#!/bin/bash

# bash -x runScaletest.sh <testid> <blocksize> <# of fio pods>

set -e
mkdir ./$1
count=$3

podname=$1

# create the yamls
for i in $(seq 1 $count)
do
        sed "s/@pvc@/$podname$i/g" fiopvctemplate.yaml > $1/fiopvc$i.yaml
        sed "s/@podname@/$podname$i/g" fioload-template.yaml > $1/fio$i.yaml
        sed -i "s/@output@/fio$i/g" $1/fio$i.yaml
        sed -i "s/@pvc@/$podname$i/g" $1/fio$i.yaml
        sed -i "s/@testid@/$1/g" $1/fio$i.yaml
        sed -i "s/@bs@/$2/g" $1/fio$i.yaml
done

cp getresults.sh $1/
cd $1

# cleanup any pending pods, pvcs
for i in $(seq 1 $count)
do
	cnt=`kubectl get pods -l app=$1 | grep -w $podname$i | wc -l`
	if [ $cnt -ne 0 ]
	then
		kubectl delete pod $podname$i
	fi

	cnt=`kubectl get pvc | grep -w $podname$i | wc -l`
	if [ $cnt -ne 0 ]
	then
		kubectl delete pvc $podname$i
	fi
done

# cleanup in the worker nodes of any /mnt/<output dir>
#for i in bmath-test75-worker01 bmath-test75-worker02 bmath-test75-worker03 bmath-test75-worker04
for i in @nodes@
do
        name=`echo $i | sed "s/-//g"`
        exists=`kubectl exec $name -- ls -ltr $1.tar.gz | wc -l`
        if [ $exists -eq 1 ]
        then
                kubectl exec $name -- rm $1.tar.gz
        fi

	exists=`kubectl exec $name -- ls -ltr /mnt | grep -w $1 | wc -l`
        if [ $exists -eq 1 ]
        then
                kubectl exec $name -- rm -rf /mnt/$1
        fi
done

# apply pvc yamls
for i in $(seq 1 $count)
do
	kubectl apply -f fiopvc$i.yaml
done

# wait for all cvr to be healthy
for i in $(seq 1 $count)
do
	cnt=`kubectl get pvc $podname$i -o jsonpath='{.status.phase}' | grep -w Bound | wc -l`
	while [ $cnt -ne 1 ]
	do
		sleep 3
		cnt=`kubectl get pvc $podname$i -o jsonpath='{.status.phase}' | grep -w Bound | wc -l`
	done
	pv=`kubectl get pvc $podname$i -o jsonpath='{.spec.volumeName}'`
	echo $pv
	cnt=`kubectl get cvr -A | grep $pv | grep -w Healthy | wc -l`
	while [ $cnt -ne 3 ]
	do
		sleep 3
		cnt=`kubectl get cvr -A | grep $pv | grep -w Healthy | wc -l`
	done
	kubectl get cvr -A | grep $pv
done

for i in $(seq 1 $count)
do
        kubectl apply -f fio$i.yaml
done
cnt=0
while [ $cnt -ne $count ]
do
        cnt=`kubectl get pods -l app=$1 | grep -w Completed | wc -l`
        echo "$cnt completed"
        sleep 10
done
bash -x ./getresults.sh $1
for i in $(seq 1 $count)
do
        kubectl delete -f fio$i.yaml
        kubectl delete -f fiopvc$i.yaml
done
