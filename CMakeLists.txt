# Copyright 2006 Milan Digital Audio LLC
# Copyright 2009-2025 GrandOrgue contributors (see AUTHORS)
# License GPL-2.0 or later
# (https://www.gnu.org/licenses/old-licenses/gpl-2.0.html).

cmake_minimum_required(VERSION 3.10)

# Project version numbers
if(NOT DEFINED VERSION)
  file(STRINGS "version.txt" VERSION)
  if(NOT VERSION)
    message(FATAL_ERROR "Unable to get version from version.txt")
  endif()
endif()

project(
  WxTestSpinCtrl
  VERSION "${VERSION}"
  DESCRIPTION "GrandOrgue - free pipe organ simulator"
  LANGUAGES CXX C
  HOMEPAGE_URL "https://github.com/GrandOrgue/grandorgue"
)
set(NUM_VERSION "${PROJECT_VERSION}")
string(REPLACE "." "," NUM_WIN_VERSION ${NUM_VERSION})

if(NOT DEFINED BUILD_VERSION)
  set(BUILD_VERSION "0.local")
elseif(NOT BUILD_VERSION)
  set(BUILD_VERSION "0.0")
endif()


if (NOT DEFINED GO_BUILD_TESTING OR GO_BUILD_TESTING STREQUAL "")
  set(GO_BUILD_TESTING ${BUILD_TESTING})
endif()

set(FULL_VERSION "${PROJECT_VERSION}-${BUILD_VERSION}")

# Set GITHUB_PROJECT variable that is used to configure update checking
if (NOT DEFINED GITHUB_PROJECT)
  set(GITHUB_PROJECT "GrandOrgue/grandorgue")
endif()

# Define a c++ standard
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_STANDARD 20 CACHE STRING "The C++ standard whose features are requested to build this project")

# Build configuration options
if (WIN32 OR APPLE)
   option(INSTALL_DEPEND      "Copy dependencies (wxWidgets libraries and Translations) on installation" ON)
else ()
   option(INSTALL_DEPEND      "Copy dependencies (wxWidgets libraries and Translations) on installation" OFF)
endif ()
option(GO_SEPARATE_LINUX_PACKAGES "Generate separate linux packages for resources and demo" OFF)
option(USE_BUILD_SYSTEM_LIBDIR "Use build system (distro-specific) libdir (Linux only)" OFF)

# only use options supported by the compiler
include(CheckIncludeFileCXX)
include(CheckFunctionExists)
include(FindPkgConfig)
include(${CMAKE_SOURCE_DIR}/cmake/AddOption.cmake)
include(${CMAKE_SOURCE_DIR}/cmake/AddCXXOption.cmake)
include(${CMAKE_SOURCE_DIR}/cmake/BuildExecutable.cmake)

IF (APPLE)
  set(BININSTDIR "${PROJECT_NAME}.app/Contents/MacOS")
  SET(LIBINSTDIR "${PROJECT_NAME}.app/Contents/Frameworks")
  SET(RESOURCEINSTDIR "${PROJECT_NAME}.app/Contents/Resources")
  SET(RPATH_PREFIX "${PROJECT_NAME}.app/Contents/Frameworks")
ELSE()
  set(BININSTDIR "bin")
  IF (WIN32)
    SET(LIBINSTDIR "bin")
  ELSEIF (USE_BUILD_SYSTEM_LIBDIR)
    # See https://cmake.org/cmake/help/latest/module/GNUInstallDirs.html for
    # the purpose of this module
    include(GNUInstallDirs)
    SET(LIBINSTDIR "${CMAKE_INSTALL_LIBDIR}" CACHE STRING "library directory")
  ELSE ()
    SET(LIBINSTDIR "lib" CACHE STRING "library directory")
  ENDIF ()
  SET(RESOURCEINSTDIR "share/${PROJECT_NAME}")
  SET(RPATH_PREFIX "$ORIGIN")
ENDIF()
SET(BINDIR "${CMAKE_BINARY_DIR}/${BININSTDIR}")
SET(LIBDIR "${CMAKE_BINARY_DIR}/${LIBINSTDIR}")
SET(RESOURCEDIR "${CMAKE_BINARY_DIR}/${RESOURCEINSTDIR}")

if (APPLE AND INSTALL_DEPEND STREQUAL "ON")
  set(OBJECT_FIXUP_REQUIRED "ON")
else()
  set(OBJECT_FIXUP_REQUIRED "OFF")
endif()

file(RELATIVE_PATH RPATH "${BINDIR}" "${LIBDIR}")
SET(CMAKE_BUILD_WITH_INSTALL_RPATH FALSE)
SET(CMAKE_SKIP_BUILD_RPATH  FALSE)
SET(CMAKE_INSTALL_RPATH "${RPATH_PREFIX}/${RPATH}")
SET(CMAKE_INSTALL_RPATH_USE_LINK_PATH FALSE)

# setup compiler flags for debug vs release compiles
add_option(-Wall)
if (CMAKE_BUILD_TYPE STREQUAL "Debug")
  add_option(-g3)
else()
  add_option(-O3)
  add_option(-g)
  add_definitions(-DNDEBUG)
  add_option(-fomit-frame-pointer)
  add_option(-funroll-loops)
  add_option(-ffast-math)
endif ()

# include libcurl for automatic cheking for updates
# exports CURL::libcurl that can be used in target_link_libraries
find_package(wxWidgets REQUIRED base)

message(STATUS "  wxWidgets Unicode?          : ${wxWidgets_USE_UNICODE}")
message(STATUS "  wxWidgets Debug?            : ${wxWidgets_USE_DEBUG}")
message(STATUS "  wxWidgets Static linking    : ${wxWidgets_USE_STATIC}")
message(STATUS "  wxWidgets version           : ${wxWidgets_VERSION}")
message(STATUS "  wxWidgets config binary     : ${wxWidgets_CONFIG_EXECUTABLE}")
message(STATUS "  wxWidgets configuration     : ${wxWidgets_CONFIGURATION}")
message(STATUS "============================================================================")

add_subdirectory(src)

# packaging

# deal with possible package names among grandorgue, grandorgue-wx30, grandorgue-wx32
set(BASE_PACKAGE_NAME "wxtestspinctrl")

set(OTHER_PACKAGE_NAMES "${BASE_PACKAGE_NAME}" "${BASE_PACKAGE_NAME}-wx30" "${BASE_PACKAGE_NAME}-wx32")
set(CPACK_PACKAGE_NAME "${BASE_PACKAGE_NAME}")
if(CMAKE_PACKAGE_SUFFIX)
  set(CPACK_PACKAGE_NAME "${BASE_PACKAGE_NAME}-${CMAKE_PACKAGE_SUFFIX}")
endif()
list(REMOVE_ITEM OTHER_PACKAGE_NAMES "${CPACK_PACKAGE_NAME}")
if(NOT GO_SEPARATE_LINUX_PACKAGES)
  # For automatic removal of previously installed subpackages
  list(APPEND OTHER_PACKAGE_NAMES "${BASE_PACKAGE_NAME}-resources" "${BASE_PACKAGE_NAME}-demo")
endif()

set(CPACK_PACKAGE_VENDOR "GrandOrgue contributors")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "OpenSource Virtual Pipe Organ Software")
set(
  CPACK_PACKAGE_DESCRIPTION
  "GrandOrgue is a virtual pipe organ sample player application"
)
set(CPACK_PACKAGE_VERSION ${PROJECT_VERSION})
set(CPACK_PACKAGE_RELEASE ${BUILD_VERSION})

set(CPACK_PACKAGE_INSTALL_DIRECTORY ${CPACK_PROJECT_NAME})
set(CPACK_PACKAGE_CONTACT "osamarin68@gmail.com")
set(CPACK_PACKAGE_EXECUTABLES ${CPACK_PROJECT_NAME} ${CPACK_PROJECT_NAME})

set(CPACK_SOURCE_IGNORE_FILES "/\\\\.git/" "/build/")

# components
set(CPACK_COMPONENTS_ALL Unspecified resources demo)
set(CPACK_COMPONENT_UNSPECIFIED_DISPLAY_NAME ${CPACK_PROJECT_NAME})

set(CPACK_COMPONENT_RESOURCES_DISPLAY_NAME "GrandOrgue Resource Files")
set(
  CPACK_COMPONENT_RESOURCES_DESCRIPTION
  "This package contains the various resource files for GrandOrgue"
)

set(CPACK_COMPONENT_DEMO_DISPLAY_NAME "GrandOrgue Demo Sampleset")
set(
  CPACK_COMPONENT_DEMO_DESCRIPTION 
  "This package contains the demo sampleset for GrandOrgue"
)

set(CPACK_COMPONENT_UNSPECIFIED_HIDDEN OFF)
set(CPACK_COMPONENT_UNSPECIFIED_DEPENDS resources)
set(CPACK_COMPONENT_DEMO_DEPENDS Unspecified)

if (APPLE)
  # see the following URL for information about these variables
  # https://developer.apple.com/library/mac/#documentation/General/Reference/InfoPlistKeyReference/Articles/CoreFoundationKeys.html
  set(BUNDLE_CFBundleShortVersionString ${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_STAGE})
  set(BUNDLE_CFBundleVersion ${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_STAGE})

  set(CPACK_PACKAGE_ICON "${RESOURCEDIR}/GrandOrgue.icns")

  configure_file(${CMAKE_SOURCE_DIR}/src/grandorgue/resource/Info.plist.in ${CMAKE_BINARY_DIR}/${PROJECT_NAME}.app/Contents/Info.plist)
  INSTALL(FILES ${CMAKE_BINARY_DIR}/${PROJECT_NAME}.app/Contents/Info.plist DESTINATION "${PROJECT_NAME}.app/Contents/")

  add_custom_target(
    macOSApplication
    ALL
    DEPENDS GrandOrgue GrandOrgueTool GrandOrguePerfTest resources # run after building these targets
    COMMAND "${CMAKE_COMMAND}" -DAPP_DIR="${CMAKE_BINARY_DIR}" -P "${CMAKE_SOURCE_DIR}/cmake/SignMacOSApp.cmake"
  )

  set(CPACK_SYSTEM_NAME "macOS")
  set(CPACK_GENERATOR DragNDrop)
  set(CPACK_PRE_BUILD_SCRIPTS "${CMAKE_SOURCE_DIR}/cmake/SignMacOSApp.cmake")

elseif (WIN32)

  if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    set(CPACK_STRIP_FILES OFF)
  else()
    set(CPACK_STRIP_FILES ON)
  endif()

  set (CPACK_SYSTEM_NAME "windows")
  set (CPACK_GENERATOR ZIP)
elseif(${CMAKE_SYSTEM_NAME} MATCHES "Linux")

  if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    set(CPACK_STRIP_FILES OFF)
  else()
    set(CPACK_STRIP_FILES ON)
  endif()

  set(CPACK_SYSTEM_NAME "linux")
  set(CPACK_GENERATOR TGZ RPM DEB)

  # prevent rpmlint errors
  set(
    CPACK_RPM_EXCLUDE_FROM_AUTO_FILELIST_ADDITION
    /usr/share/icons
    /usr/share/man
    /usr/share/man/man1
  )
endif()

set(CPACK_PACKAGE_FILE_NAME "${CPACK_PACKAGE_NAME}-${CPACK_PACKAGE_VERSION}-${CPACK_PACKAGE_RELEASE}.${CPACK_SYSTEM_NAME}.${CMAKE_SYSTEM_PROCESSOR}")

include(CPack)

message(STATUS "  Project                     : ${PROJECT_NAME}")
message(STATUS "  Description                 : ${CPACK_PACKAGE_DESCRIPTION_SUMMARY}")
message(STATUS "  Version                     : ${VERSION}")
message(STATUS "  Build                       : ${CPACK_PACKAGE_RELEASE}")
message(STATUS "  Package name                : ${CPACK_PACKAGE_NAME}")
message(STATUS "============================================================================")
message(STATUS " ")
