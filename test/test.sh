#!/bin/bash

for i in files/{.vimrc,ansible.cfg,inventory}; 
do
  echo ${i} > ${i}
done  