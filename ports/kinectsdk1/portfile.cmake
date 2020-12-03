include(vcpkg_common_functions)

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm")
    message(FATAL_ERROR "This port does not currently support architecture: ${VCPKG_TARGET_ARCHITECTURE}")
endif()

set(KINECTSDK10_VERSION "v1.8")
vcpkg_download_distfile(KINECTSDK10_INSTALLER
    URLS "https://download.microsoft.com/download/E/1/D/E1DEC243-0389-4A23-87BF-F47DE869FC1A/KinectSDK-${KINECTSDK10_VERSION}-Setup.exe"
    FILENAME "KinectSDK-${KINECTSDK10_VERSION}-Setup.exe"
    SHA512 ee8a0f70c86aad80fe214108e315e4550a90ed39f278ce00a7137532174ee5bf3bdeb1d0b499fc5ffdb5e176adecfd68963ee3731e1d2f00d69d32d1b8a3c555
)

vcpkg_find_acquire_program(DARK)

set(KINECTSDK10_WIX_INSTALLER "${KINECTSDK10_INSTALLER}")
set(KINECTSDK10_WIX_EXTRACT_DIR "${CURRENT_BUILDTREES_DIR}/src/installer/wix")
vcpkg_execute_required_process(
    COMMAND ${DARK} -x ${KINECTSDK10_WIX_EXTRACT_DIR} ${KINECTSDK10_WIX_INSTALLER}
    WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}
    LOGNAME extract_wix_installer
)

file(TO_NATIVE_PATH "${KINECTSDK10_WIX_EXTRACT_DIR}/AttachedContainer/KinectSDK-${KINECTSDK10_VERSION}-${VCPKG_TARGET_ARCHITECTURE}.msi" KINECTSDK10_MSI_INSTALLER)
file(TO_NATIVE_PATH "${CURRENT_BUILDTREES_DIR}/src/installer/msi/${VCPKG_TARGET_ARCHITECTURE}" KINECTSDK10_MSI_EXTRACT_DIR)
file(TO_NATIVE_PATH "${CURRENT_BUILDTREES_DIR}/msiexec.log" MSIEXEC_LOG_PATH)
set(BATCH_FILE ${CURRENT_BUILDTREES_DIR}/msiextract-msmpi.bat)
file(WRITE ${BATCH_FILE} "msiexec.exe /a \"${KINECTSDK10_MSI_INSTALLER}\" /qn /log \"${MSIEXEC_LOG_PATH}\" TARGETDIR=\"${KINECTSDK10_MSI_EXTRACT_DIR}\"")
vcpkg_execute_required_process(
    COMMAND ${BATCH_FILE}
    WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}
    LOGNAME extract_msi_installer_${VCPKG_TARGET_ARCHITECTURE}
)

set(KINECTSDK10_DIR "${CURRENT_BUILDTREES_DIR}/src/installer/msi/${VCPKG_TARGET_ARCHITECTURE}/Microsoft SDKs/Kinect/${KINECTSDK10_VERSION}")

file(
    INSTALL
        "${KINECTSDK10_DIR}/inc/NuiApi.h"
        "${KINECTSDK10_DIR}/inc/NuiImageCamera.h"
        "${KINECTSDK10_DIR}/inc/NuiSensor.h"
        "${KINECTSDK10_DIR}/inc/NuiSkeleton.h"
    DESTINATION
        ${CURRENT_PACKAGES_DIR}/include
)

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
    set(ARCHITECTURE x86)
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(ARCHITECTURE amd64)
else()
    message(FATAL_ERROR "This port does not currently support architecture: ${VCPKG_TARGET_ARCHITECTURE}")
endif()

file(
    INSTALL
        "${KINECTSDK10_DIR}/lib/${ARCHITECTURE}/Kinect10.lib"
    DESTINATION
        ${CURRENT_PACKAGES_DIR}/lib
)

file(
    INSTALL
        "${KINECTSDK10_DIR}/lib/${ARCHITECTURE}/Kinect10.lib"
    DESTINATION
        ${CURRENT_PACKAGES_DIR}/debug/lib
)

# Handle copyright
file(COPY "${KINECTSDK10_DIR}/SDKEula.rtf" DESTINATION ${CURRENT_PACKAGES_DIR}/share/kinectsdk1)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/kinectsdk1/SDKEula.rtf ${CURRENT_PACKAGES_DIR}/share/kinectsdk1/copyright)