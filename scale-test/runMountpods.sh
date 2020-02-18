#!/bin/bash
#for i in bmath-test75-storage01 bmath-test75-storage02 bmath-test75-storage03
for i in @nodes@
do
	name=`echo $i | sed "s/-//g"`
	sed "s/@podname@/$name/g" mountpodtemplate.yaml > mountpod$i.yaml
	sed -i "s/@nodename@/$i/g" mountpod$i.yaml
done
for i in @nodes@
do
	kubectl apply -f mountpod$i.yaml
done
