# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/range
    REF boost-${VERSION}
    SHA512 97e6c2bcfa6d12c58b3cd407c21867ab0db56eb1be87adc06d61065d3913c492dd13ef8bef2375c3e0afc28f46388e449e5d96a7eec03c6c6c4c3fbd5f0c25e5
    HEAD_REF master
)

set(FEATURE_OPTIONS "")
boost_configure_and_install(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
)
