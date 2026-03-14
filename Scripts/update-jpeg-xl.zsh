#!/bin/zsh

##
##  update-jpeg-xl.zsh
##  swift-jpeg-xl
##
##  Created by Fang Ling on 2026/3/14.
##
##  Licensed under the Apache License, Version 2.0 (the "License");
##  you may not use this file except in compliance with the License.
##  You may obtain a copy of the License at
##
##    http://www.apache.org/licenses/LICENSE-2.0
##
##  Unless required by applicable law or agreed to in writing, software
##  distributed under the License is distributed on an "AS IS" BASIS,
##  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
##  See the License for the specific language governing permissions and
##  limitations under the License.
##

# This script creates a copy of libjxl that is suitable for building with the
# Swift Package Manager.
#
# Usage:
#   Run this script in the package root. It will place a local copy of the
#   libjxl sources in Sources/CJPEGXL, Sources/CJPEGXLExtras,
#   Sources/CJPEGXLTools, Sources/cjxl, Sources/djxl.
#   Any prior contents of those directories will be deleted.
#

set -euo pipefail

CURRENT_WORKING_DIRECTORY=$(pwd)
TEMPORARY_DIRECTORY=$(mktemp -d /tmp/swift-jpeg-xl-XXXXXX)
SOURCE_DIRECTORY="${TEMPORARY_DIRECTORY}/Sources/libjxl"
DESTINATION_DIRECTORY="Sources/CJPEGXL"
EXTRA_DESTINATION_DIRECTORY="Sources/CJPEGXLExtras"
TOOL_DESTINATION_DIRECTORY="Sources/CJPEGXLTools"
CJXL_DESTINATION_DIRECTORY="Sources/cjxl"
DJXL_DESTINATION_DIRECTORY="Sources/djxl"
TRASH_DIRECTORY="${TEMPORARY_DIRECTORY}/Trash"
SOURCES=(
  "lib/jxl/*.cc"
  "lib/jxl/*.h"
  "lib/jxl/base/*.h"
  "lib/jxl/butteraugli/*.cc"
  "lib/jxl/butteraugli/*.h"
  "lib/jxl/cms/*.cc"
  "lib/jxl/cms/*.h"
  "lib/jxl/jpeg/*.cc"
  "lib/jxl/jpeg/*.h"
  "lib/jxl/modular/*.cc"
  "lib/jxl/modular/*.h"
  "lib/jxl/modular/encoding/*.cc"
  "lib/jxl/modular/encoding/*.h"
  "lib/jxl/modular/transform/*.cc"
  "lib/jxl/modular/transform/*.h"
  "lib/jxl/render_pipeline/*.cc"
  "lib/jxl/render_pipeline/*.h"
  "lib/threads/*.cc"
  "lib/threads/*.h"
)
EXTRA_SOURCES=(
  "lib/extras/*.cc"
  "lib/extras/*.h"
  "lib/extras/dec/*.cc"
  "lib/extras/dec/*.h"
  "lib/extras/enc/*.cc"
  "lib/extras/enc/*.h"
)
TOOL_SOURCES=(
  "tools/args.h"
  "tools/cmdline.cc"
  "tools/cmdline.h"
  "tools/codec_config.cc"
  "tools/codec_config.h"
  "tools/file_io.h"
  "tools/speed_stats.cc"
  "tools/speed_stats.h"
  "tools/tool_version.cc"
  "tools/tool_version.h"
)
CJXL_SOURCES=(
  "tools/cjxl_main.cc"
)
DJXL_SOURCES=(
  "tools/djxl_main.cc"
)
EXCLUDES=(
  "lib/jxl/*_test.cc"
  "lib/jxl/test_image.cc"
  "lib/jxl/test_utils.cc"
  "lib/jxl/*_gbench.cc"
  "lib/jxl/butteraugli/*_test.cc"
  "lib/jxl/cms/*_test.cc"
  "lib/jxl/render_pipeline/*_test.cc"
  "lib/threads/*_test.cc"
)
EXTRA_EXCLUDES=(
  "lib/extras/*_test.cc"
  "lib/extras/*_gbench.cc"
  "lib/extras/dec/*_test.cc"
  "lib/extras/dec/jpegli.cc"
  "lib/extras/dec/jpegli.h"
  "lib/extras/enc/jpegli.cc"
  "lib/extras/enc/jpegli.h"
)

# Libjxl revision must be passed as the first argument to this script.
if [ "$#" -gt 0 ]; then
  LIBJXL_REVISION="$1"
else
  echo "Usage: $0 <libjxl-revision>"
  exit 1
fi

echo "=========================================="
echo "TRASHING any previously-copied libjxl code"
echo "=========================================="
mkdir -p "${TRASH_DIRECTORY}/CJPEGXL"
mkdir -p "${TRASH_DIRECTORY}/CJPEGXLExtras"
mkdir -p "${TRASH_DIRECTORY}/CJPEGXLTools"
mkdir -p "${TRASH_DIRECTORY}/cjxl"
mkdir -p "${TRASH_DIRECTORY}/djxl"
mv "${DESTINATION_DIRECTORY}/"* "${TRASH_DIRECTORY}/CJPEGXL" || true
mv "${EXTRA_DESTINATION_DIRECTORY}/"* "${TRASH_DIRECTORY}/CJPEGXLExtras" || true
mv "${TOOL_DESTINATION_DIRECTORY}/"* "${TRASH_DIRECTORY}/CJPEGXLTools" || true
mv "${CJXL_DESTINATION_DIRECTORY}/"* "${TRASH_DIRECTORY}/cjxl" || true
mv "${DJXL_DESTINATION_DIRECTORY}/"* "${TRASH_DIRECTORY}/djxl" || true

echo "================="
echo "PREPARING libjxl"
echo "================="
mkdir -p "${SOURCE_DIRECTORY}"
git clone https://github.com/libjxl/libjxl.git "${SOURCE_DIRECTORY}"
cd "${SOURCE_DIRECTORY}"
git checkout "${LIBJXL_REVISION}"
cd "${CURRENT_WORKING_DIRECTORY}"

echo "=============="
echo "COPYING libjxl"
echo "=============="
mkdir -p "${DESTINATION_DIRECTORY}/libjxl"
for SOURCE in "${SOURCES[@]}"
do
  for FILE in "${SOURCE_DIRECTORY}/"${~SOURCE}
  do
    FILE_PATH=${FILE#"$SOURCE_DIRECTORY"}
    DESTINATION="${DESTINATION_DIRECTORY}/libjxl${FILE_PATH}"
    mkdir -p $(dirname "${DESTINATION}")

    cp "${FILE}" "${DESTINATION}"
  done
done
for EXTRA_SOURCE in "${EXTRA_SOURCES[@]}"
do
  for FILE in "${SOURCE_DIRECTORY}/"${~EXTRA_SOURCE}
  do
    FILE_PATH=${FILE#"$SOURCE_DIRECTORY"}
    DESTINATION="${EXTRA_DESTINATION_DIRECTORY}/libjxl${FILE_PATH}"
    mkdir -p $(dirname "${DESTINATION}")

    cp "${FILE}" "${DESTINATION}"
  done
done
for TOOL_SOURCE in "${TOOL_SOURCES[@]}"
do
  for FILE in "${SOURCE_DIRECTORY}/"${~TOOL_SOURCE}
  do
    FILE_PATH=${FILE#"$SOURCE_DIRECTORY"}
    DESTINATION="${TOOL_DESTINATION_DIRECTORY}/${FILE_PATH}"
    mkdir -p $(dirname "${DESTINATION}")

    cp "${FILE}" "${DESTINATION}"
  done
done
for CJXL_SOURCE in "${CJXL_SOURCES[@]}"
do
  for FILE in "${SOURCE_DIRECTORY}/"${~CJXL_SOURCE}
  do
    FILE_PATH=${FILE#"$SOURCE_DIRECTORY"}
    DESTINATION="${CJXL_DESTINATION_DIRECTORY}/${FILE_PATH}"
    mkdir -p $(dirname "${DESTINATION}")

    cp "${FILE}" "${DESTINATION}"
  done
done
for DJXL_SOURCE in "${DJXL_SOURCES[@]}"
do
  for FILE in "${SOURCE_DIRECTORY}/"${~DJXL_SOURCE}
  do
    FILE_PATH=${FILE#"$SOURCE_DIRECTORY"}
    DESTINATION="${DJXL_DESTINATION_DIRECTORY}/${FILE_PATH}"
    mkdir -p $(dirname "${DESTINATION}")

    cp "${FILE}" "${DESTINATION}"
  done
done
for EXCLUDE in "${EXCLUDES[@]}"
do
  rm -rf "${DESTINATION_DIRECTORY}/libjxl/"${~EXCLUDE}
done
for EXTRA_EXCLUDE in "${EXTRA_EXCLUDES[@]}"
do
  rm -rf "${EXTRA_DESTINATION_DIRECTORY}/libjxl/"${~EXTRA_EXCLUDE}
done
mkdir -p "${DESTINATION_DIRECTORY}/include/jxl"
mkdir -p "${EXTRA_DESTINATION_DIRECTORY}/include/lib/extras/dec"
mkdir -p "${EXTRA_DESTINATION_DIRECTORY}/include/lib/extras/enc"
mkdir -p "${TOOL_DESTINATION_DIRECTORY}/include/tools"
cp \
  "${SOURCE_DIRECTORY}/lib/include/jxl/"*.h \
  "${DESTINATION_DIRECTORY}/include/jxl"
# Remove the cxx headers
rm "${DESTINATION_DIRECTORY}/include/jxl/"*_cxx.h
mv "${EXTRA_DESTINATION_DIRECTORY}/libjxl/lib" "${EXTRA_DESTINATION_DIRECTORY}"
rmdir "${EXTRA_DESTINATION_DIRECTORY}/libjxl"
mv \
  "${EXTRA_DESTINATION_DIRECTORY}/lib/extras/"*.h \
  "${EXTRA_DESTINATION_DIRECTORY}/include/lib/extras"
mv \
  "${EXTRA_DESTINATION_DIRECTORY}/lib/extras/dec/"*.h \
  "${EXTRA_DESTINATION_DIRECTORY}/include/lib/extras/dec"
mv \
  "${EXTRA_DESTINATION_DIRECTORY}/lib/extras/enc/"*.h \
  "${EXTRA_DESTINATION_DIRECTORY}/include/lib/extras/enc"
# Patch the include path for mmap.cc
sed -i '' '6s|#include "mmap.h"|#include "lib/extras/mmap.h"|' \
  "${EXTRA_DESTINATION_DIRECTORY}/lib/extras/mmap.cc"
# Move template files to include folder
mv \
  "${EXTRA_DESTINATION_DIRECTORY}/lib/extras/metrics.cc" \
  "${EXTRA_DESTINATION_DIRECTORY}/include/lib/extras"
mv \
  "${EXTRA_DESTINATION_DIRECTORY}/lib/extras/tone_mapping.cc" \
  "${EXTRA_DESTINATION_DIRECTORY}/include/lib/extras"
mv \
  "${TOOL_DESTINATION_DIRECTORY}/tools/"*.h \
  "${TOOL_DESTINATION_DIRECTORY}/include/tools"
cp "${SOURCE_DIRECTORY}/LICENSE" "${DESTINATION_DIRECTORY}/LICENSE.txt"
cp "${SOURCE_DIRECTORY}/LICENSE" "${EXTRA_DESTINATION_DIRECTORY}/LICENSE.txt"
cp "${SOURCE_DIRECTORY}/LICENSE" "${TOOL_DESTINATION_DIRECTORY}/LICENSE.txt"
cp "${SOURCE_DIRECTORY}/LICENSE" "${CJXL_DESTINATION_DIRECTORY}/LICENSE.txt"
cp "${SOURCE_DIRECTORY}/LICENSE" "${DJXL_DESTINATION_DIRECTORY}/LICENSE.txt"

echo "======================="
echo "WRITING generated files"
echo "======================="
cat << EOF > "${DESTINATION_DIRECTORY}/include/jxl/jxl_threads_export.h"
#ifndef JXL_THREADS_EXPORT_H
#define JXL_THREADS_EXPORT_H

#ifdef JXL_THREADS_STATIC_DEFINE
#  define JXL_THREADS_EXPORT
#  define JXL_THREADS_NO_EXPORT
#else
#  ifndef JXL_THREADS_EXPORT
#    ifdef JXL_THREADS_INTERNAL_LIBRARY_BUILD
        /* We are building this library */
#      define JXL_THREADS_EXPORT __attribute__((visibility("default")))
#    else
        /* We are using this library */
#      define JXL_THREADS_EXPORT __attribute__((visibility("default")))
#    endif
#  endif

#  ifndef JXL_THREADS_NO_EXPORT
#    define JXL_THREADS_NO_EXPORT __attribute__((visibility("hidden")))
#  endif
#endif

#ifndef JXL_THREADS_DEPRECATED
#  define JXL_THREADS_DEPRECATED __attribute__ ((__deprecated__))
#endif

#ifndef JXL_THREADS_DEPRECATED_EXPORT
# define JXL_THREADS_DEPRECATED_EXPORT JXL_THREADS_EXPORT JXL_THREADS_DEPRECATED
#endif

#ifndef JXL_THREADS_DEPRECATED_NO_EXPORT
#define JXL_THREADS_DEPRECATED_NO_EXPORT \
  JXL_THREADS_NO_EXPORT JXL_THREADS_DEPRECATED
#endif

/* NOLINTNEXTLINE(readability-avoid-unconditional-preprocessor-if) */
#if 0 /* DEFINE_NO_DEPRECATED */
#  ifndef JXL_THREADS_NO_DEPRECATED
#    define JXL_THREADS_NO_DEPRECATED
#  endif
#endif

#endif /* JXL_THREADS_EXPORT_H */
EOF
cat << EOF > "${DESTINATION_DIRECTORY}/include/jxl/jxl_export.h"
#ifndef JXL_EXPORT_H
#define JXL_EXPORT_H

#ifdef JXL_STATIC_DEFINE
#  define JXL_EXPORT
#  define JXL_NO_EXPORT
#else
#  ifndef JXL_EXPORT
#    ifdef JXL_INTERNAL_LIBRARY_BUILD
        /* We are building this library */
#      define JXL_EXPORT __attribute__((visibility("default")))
#    else
        /* We are using this library */
#      define JXL_EXPORT __attribute__((visibility("default")))
#    endif
#  endif

#  ifndef JXL_NO_EXPORT
#    define JXL_NO_EXPORT __attribute__((visibility("hidden")))
#  endif
#endif

#ifndef JXL_DEPRECATED
#  define JXL_DEPRECATED __attribute__ ((__deprecated__))
#endif

#ifndef JXL_DEPRECATED_EXPORT
#  define JXL_DEPRECATED_EXPORT JXL_EXPORT JXL_DEPRECATED
#endif

#ifndef JXL_DEPRECATED_NO_EXPORT
#  define JXL_DEPRECATED_NO_EXPORT JXL_NO_EXPORT JXL_DEPRECATED
#endif

/* NOLINTNEXTLINE(readability-avoid-unconditional-preprocessor-if) */
#if 0 /* DEFINE_NO_DEPRECATED */
#  ifndef JXL_NO_DEPRECATED
#    define JXL_NO_DEPRECATED
#  endif
#endif

#endif /* JXL_EXPORT_H */
EOF
cat << EOF > "${DESTINATION_DIRECTORY}/include/jxl/version.h"
/* Copyright (c) the JPEG XL Project Authors. All rights reserved.
 *
 * Use of this source code is governed by a BSD-style
 * license that can be found in the LICENSE file.
 */

/** @addtogroup libjxl_common
 * @{
 * @file version.h
 * @brief libjxl version information
 */

#ifndef JXL_VERSION_H_
#define JXL_VERSION_H_

#define JPEGXL_MAJOR_VERSION 0 ///< JPEG XL Major version
#define JPEGXL_MINOR_VERSION 11 ///< JPEG XL Minor version
#define JPEGXL_PATCH_VERSION 2 ///< JPEG XL Patch version

/** Can be used to conditionally compile code for a specific JXL version
 * @param[maj] major version
 * @param[min] minor version
 *
 * @code
 * #if JPEGXL_NUMERIC_VERSION < JPEGXL_COMPUTE_NUMERIC_VERSION(0,8,0)
 * // use old/deprecated api
 * #else
 * // use current api
 * #endif
 * @endcode
 */
#define JPEGXL_COMPUTE_NUMERIC_VERSION(major,minor,patch) \
  (((major)<<24) | ((minor)<<16) | ((patch)<<8) | 0)

/* Numeric representation of the version */
#define JPEGXL_NUMERIC_VERSION                         \
  JPEGXL_COMPUTE_NUMERIC_VERSION(JPEGXL_MAJOR_VERSION, \
                                 JPEGXL_MINOR_VERSION, \
                                 JPEGXL_PATCH_VERSION)

#endif /* JXL_VERSION_H_ */

/** @}*/
EOF
cat << EOF > "${DESTINATION_DIRECTORY}/include/jxl/jxl_cms_export.h"
#ifndef JXL_CMS_EXPORT_H
#define JXL_CMS_EXPORT_H

#ifdef JXL_CMS_STATIC_DEFINE
#  define JXL_CMS_EXPORT
#  define JXL_CMS_NO_EXPORT
#else
#  ifndef JXL_CMS_EXPORT
#    ifdef jxl_cms_EXPORTS
        /* We are building this library */
#      define JXL_CMS_EXPORT __attribute__((visibility("default")))
#    else
        /* We are using this library */
#      define JXL_CMS_EXPORT __attribute__((visibility("default")))
#    endif
#  endif

#  ifndef JXL_CMS_NO_EXPORT
#    define JXL_CMS_NO_EXPORT __attribute__((visibility("hidden")))
#  endif
#endif

#ifndef JXL_CMS_DEPRECATED
#  define JXL_CMS_DEPRECATED __attribute__ ((__deprecated__))
#endif

#ifndef JXL_CMS_DEPRECATED_EXPORT
#  define JXL_CMS_DEPRECATED_EXPORT JXL_CMS_EXPORT JXL_CMS_DEPRECATED
#endif

#ifndef JXL_CMS_DEPRECATED_NO_EXPORT
#  define JXL_CMS_DEPRECATED_NO_EXPORT JXL_CMS_NO_EXPORT JXL_CMS_DEPRECATED
#endif

/* NOLINTNEXTLINE(readability-avoid-unconditional-preprocessor-if) */
#if 0 /* DEFINE_NO_DEPRECATED */
#  ifndef JXL_CMS_NO_DEPRECATED
#    define JXL_CMS_NO_DEPRECATED
#  endif
#endif

#endif /* JXL_CMS_EXPORT_H */
EOF

echo "========================="
echo "RECORDING libjxl revision"
echo "========================="
cat << EOF > "${DESTINATION_DIRECTORY}/revision.txt"
This directory is derived from libjxl
  cloned from https://github.com/libjxl/libjxl.git
EOF
echo -n "at revision" >> "${DESTINATION_DIRECTORY}/revision.txt"
echo " ${LIBJXL_REVISION}" >> "${DESTINATION_DIRECTORY}/revision.txt"
cp \
  "${DESTINATION_DIRECTORY}/revision.txt" \
  "${EXTRA_DESTINATION_DIRECTORY}/revision.txt"
cp \
  "${DESTINATION_DIRECTORY}/revision.txt" \
  "${TOOL_DESTINATION_DIRECTORY}/revision.txt"
cp \
  "${DESTINATION_DIRECTORY}/revision.txt" \
  "${CJXL_DESTINATION_DIRECTORY}/revision.txt"
cp \
  "${DESTINATION_DIRECTORY}/revision.txt" \
  "${DJXL_DESTINATION_DIRECTORY}/revision.txt"

echo "============================"
echo "CLEANING temporary directory"
echo "============================"
rm -rf "${TEMPORARY_DIRECTORY}"
