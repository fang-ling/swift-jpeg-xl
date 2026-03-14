// swift-tools-version: 6.2

//
//  Package.swift
//  swift-jpeg-xl
//
//  Created by Fang Ling on 2026/3/14.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import PackageDescription

let dependencies = [
  ("https://github.com/fang-ling/swift-brotli", "snapshot"),
  ("https://github.com/fang-ling/swift-highway", "snapshot"),
  ("https://github.com/fang-ling/swift-little-cms", "snapshot"),
  ("https://github.com/fang-ling/swift-png", "snapshot")
]

let package = Package(
  name: "swift-jpeg-xl",
  products: [
    .library(name: "CJPEGXL", targets: ["CJPEGXL"])
  ],
  dependencies: dependencies.map({ .package(url: $0.0, branch: $0.1) }),
  targets: [
    .target(
      name: "CJPEGXL",
      dependencies: [
        .product(name: "CBrotli", package: "swift-brotli"),
        .product(name: "CHighway", package: "swift-highway"),
        .product(name: "CLittleCMS", package: "swift-little-cms")
      ],
      cxxSettings: [
        .headerSearchPath("libjxl")
      ]
    ),
    .target(
      name: "CJPEGXLExtras",
      dependencies: [
        "CJPEGXL",
        .product(name: "CPNG", package: "swift-png")
      ],
      cxxSettings: [
        .define("JPEGXL_ENABLE_APNG"),
        .headerSearchPath("../CJPEGXL/libjxl")
      ]
    ),
    .target(
      name: "CJPEGXLTools",
      dependencies: [
        .product(name: "CHighway", package: "swift-highway")
      ],
      cxxSettings: [
        .define("JPEGXL_VERSION", to: #""0.11.2""#)
      ]
    ),
    .executableTarget(
      name: "cjxl",
      dependencies: [
        "CJPEGXL",
        "CJPEGXLExtras",
        "CJPEGXLTools"
      ],
      cxxSettings: [
        .headerSearchPath("../CJPEGXL/libjxl")
      ]
    ),
    .executableTarget(
      name: "djxl",
      dependencies: [
        "CJPEGXL",
        "CJPEGXLExtras",
        "CJPEGXLTools"
      ],
      cxxSettings: [
        .headerSearchPath("../CJPEGXL/libjxl")
      ]
    )
  ],
  cxxLanguageStandard: .cxx17
)
