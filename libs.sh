#!/bin/bash

OUTPUT_DIR=output
BUILD_DIR=$OUTPUT_DIR/build
TARGET_DIR=$OUTPUT_DIR/target
PJPROJECT_DIR=$BUILD_DIR/pjproject-2.9

if [ ! -d $TARGET_DIR/lib ];then
    mkdir -p "$TARGET_DIR/lib"
fi

for i in pjlib pjlib-util pjmedia pjnath pjsip third_party
do
    for j in `ls $PJPROJECT_DIR/$i/lib/*arm64*.a`
    do
        arg_1=""
        for k in arm64 armv7 armv7s x86_64 i386
        do
            arg_tmp=`echo $j | sed "s#arm64#${k}#g"`
            arg_1="${arg_1} ${arg_tmp}"
        done
        arg_2=`echo $j | sed "s#-arm64.*##g" | sed "s#.*\/##g"`
        # echo "$arg_1 $arg_2"
        cmd="lipo -create $arg_1 -output $TARGET_DIR/lib/$arg_2.a"
        $cmd
    done
done

