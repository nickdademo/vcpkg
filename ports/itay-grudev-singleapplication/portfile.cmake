vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO itay-grudev/SingleApplication
    REF "v${VERSION}"
    SHA512 9a63dcbfd4c80626093b23df0ee97d704b494d928b76b81e0373a0a847e73a0c4fd6557e338221c473412394c4ab3456d90e1e5c7894112b08ce7f11c9e66e58
    HEAD_REF master
)

list(LENGTH FEATURES num_features)
if(num_features GREATER "2")
    message(FATAL_ERROR "Can not select multiple Qt classes to inherit from. Disable default features to disable the default QCoreApplication inheritance.")
endif()

if("qguiapplication" IN_LIST FEATURES)
    set(QAPPLICATION_CLASS QGuiApplication)
elseif("qapplication" IN_LIST FEATURES)
    set(QAPPLICATION_CLASS QApplication)
elseif("qcoreapplication" IN_LIST FEATURES)
    set(QAPPLICATION_CLASS QCoreApplication)
else()
    set(QAPPLICATION_CLASS QCoreApplication)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DQT_DEFAULT_MAJOR_VERSION=6
        -DQAPPLICATION_CLASS=${QAPPLICATION_CLASS}
)

vcpkg_cmake_build(TARGET SingleApplication)

file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/SingleApplication.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/SingleApplication.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
file(INSTALL "${SOURCE_PATH}/singleapplication.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

configure_file("${CMAKE_CURRENT_LIST_DIR}/Config.cmake.in" "${CURRENT_PACKAGES_DIR}/share/${PORT}/${PORT}-config.cmake" @ONLY)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")