#!/bin/sh

#  YCHOpenSourceCopyShell.sh
#  MEETPlatform_SDK_iOS
#
#  Created by Mei Jigao on 16/8/11.
#  Copyright © 2016年 MEETStudio. All rights reserved.

# 如果任何语句的执行结果不是true则退出
# set -o errexit
set -e

# bash 返回从右到左第一个以非0状态退出的管道命令的返回值，如果所有命令都成功执行时才返回0
set -o pipefail

# 执行的语句结果不是true和0，bash将无法执行到检查的代码
# 执行检查
command
if [ "$?"-ne 0 ]
then
    echo "command failed"
exit 1
fi

# 清除
xcodebuild -alltargets clean

# Product路径
ProductDir="$BUILT_PRODUCTS_DIR"
ProductPodDir="$BUILT_PRODUCTS_DIR/PodFiles"
ProductPath="$BUILT_PRODUCTS_DIR/YCHMusic.framework"

# 拷贝 Pod 管理的三方 framwwork 及其 bundle
# 参数个数 1
# 参数1: 三方库名称
CopyPodFilesWithName() {

    # 拷贝 framework 文件
    fSrc="$ProductDir/$1/$1.framework"
    mv -f "$fSrc" "$ProductPodDir"

    # 移除空文件夹
    rm -fr "$ProductDir/$1"
}

# 移除文件夹
rm -fr "$ProductPodDir"
mkdir -p "$ProductPodDir"

# 拷贝Pod Framework
CopyPodFilesWithName "FLAnimatedImage"

CopyPodFilesWithName "SDWebImage"

CopyPodFilesWithName "SVProgressHUD"
