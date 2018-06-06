#!/bin/sh

for file in StructvsClassPerformance*.swift ; do
    swiftc -g -O -whole-module-optimization -save-optimization-record -emit-sil $file > $file.sil
    swiftc -g -O -whole-module-optimization -save-optimization-record -emit-ir $file > $file.ir
    swiftc -g -O -whole-module-optimization -save-optimization-record $file
done
