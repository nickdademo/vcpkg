if(VCPKG_TARGET_IS_WINDOWS)
    set(PATCHES
        "0001-Use-libtre.patch"
        "0002-Change-zlib-lib-name-to-match-CMake-output.patch"
        "0003-Fix-WIN32-macro-checks.patch"
        "0004-Typedef-POSIX-types-on-Windows.patch"
        "0005-Include-dirent.h-for-S_ISREG-and-S_ISDIR.patch"
        "0006-Remove-Wrap-POSIX-headers.patch"
        "0007-Substitute-unistd-macros-for-MSVC.patch"
        "0008-Add-FILENO-defines.patch"
        "0010-Properly-check-for-the-presence-of-bitmasks.patch"
        "0011-Remove-pipe-related-functions-in-funcs.c.patch"
        "0012-Convert-MSYS2-paths-to-Windows-paths.patch"
        "0013-Check-for-backslash-in-argv-0-on-Windows.patch"
        "0015-MSYS2-Remove-ioctl-call.patch"
        "0016-Fix-file_famagic-function.patch"
        "0017-Change-bzlib-name-to-match-CMake-output.patch"
    )
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO file/file
    REF FILE5_46
    SHA512 fb8157ee8065feaf57412ccdeee57cd8fc853b54ac49b0ddc818eeb1ca3555a7cfd25dea08996503f7c565dcba8c57fd7e4dc5fe3452872c617f5612a94a8f0e
    HEAD_REF master
    PATCHES ${PATCHES}
)

if(VCPKG_TARGET_IS_WINDOWS)
    set(VCPKG_C_FLAGS "${VCPKG_C_FLAGS} -D_CRT_SECURE_NO_WARNINGS -D_CRT_NONSTDC_NO_WARNINGS")
    set(VCPKG_CXX_FLAGS "${VCPKG_CXX_FLAGS} -D_CRT_SECURE_NO_WARNINGS -D_CRT_NONSTDC_NO_WARNINGS")
endif()

if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    set(VCPKG_C_FLAGS "${VCPKG_C_FLAGS} -DBUILD_AS_WINDOWS_STATIC_LIBARAY")
    set(VCPKG_CXX_FLAGS "${VCPKG_CXX_FLAGS} -DBUILD_AS_WINDOWS_STATIC_LIBARAY")
endif()

set(FEATURE_OPTIONS)

macro(enable_feature feature switch)
    if("${feature}" IN_LIST FEATURES)
        list(APPEND FEATURE_OPTIONS "--enable-${switch}")
        set(has_${feature} 1)
    else()
        list(APPEND FEATURE_OPTIONS "--disable-${switch}")
        set(has_${feature} 0)
    endif()
endmacro()

enable_feature("bzip2" "bzlib")
enable_feature("zlib" "zlib")
enable_feature("lzma" "xzlib")
enable_feature("zstd" "zstdlib")

vcpkg_configure_make(
    AUTOCONFIG
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        "--disable-lzlib"
        "--disable-libseccomp"
)

if(VCPKG_CROSSCOMPILING)
    vcpkg_add_to_path(PREPEND "${CURRENT_HOST_INSTALLED_DIR}/tools/libmagic/bin")
elseif(VCPKG_TARGET_IS_WINDOWS AND VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(EXTRA_ARGS "ADD_BIN_TO_PATH")
endif()

vcpkg_install_make(${EXTRA_ARGS})
vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin")
vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/${PORT}/debug/bin")
vcpkg_fixup_pkgconfig()

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

if(VCPKG_TARGET_IS_WINDOWS)
    if(NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/${PORT}/share/misc")
        file(COPY "${CURRENT_PACKAGES_DIR}/share/${PORT}/misc/magic.mgc" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}/share/misc")
    endif()
    if(NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/${PORT}/debug/share/misc")
        file(COPY "${CURRENT_PACKAGES_DIR}/share/${PORT}/misc/magic.mgc" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}/debug/share/misc")
    endif()
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/${PORT}/man5")

include(CMakePackageConfigHelpers)
configure_package_config_file(
    "${CMAKE_CURRENT_LIST_DIR}/unofficial-${PORT}-config.cmake.in"
    "${CURRENT_PACKAGES_DIR}/share/unofficial-${PORT}/unofficial-${PORT}-config.cmake"
    INSTALL_DESTINATION "share/unofficial-${PORT}"
)

# Handle copyright and usage
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
