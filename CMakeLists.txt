# Задать третью минимальную версию CMake:
cmake_minimum_required(VERSION 3.10)

# Задать характеристики проекта "CMakeTest":
project(WxTestSpinCtrl VERSION 0.1 LANGUAGES CXX)

# Location where cmake first looks for cmake modules.
set(CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}")

##---------------------------------------------------
## Please set your wxWidgets configuration here
##--------------------------------------------------- 
 
# Here you can define what libraries of wxWidgets you need for your
# application. You can figure out what libraries you need here;
# https://www.wxwidgets.org/manuals/2.8/wx_librarieslist.html
# We need the Find package for wxWidgets to work
# NOTE: if you're using aui, include aui in this required components list.

include(FindPkgConfig)

# It was noticed that when using MinGW gcc it is essential that 'core' is mentioned before 'base'.
find_package(wxWidgets COMPONENTS core base REQUIRED)
 
##---------------------------------------------------
## Actual config file starts here
##--------------------------------------------------- 
 
# wxWidgets include (this will do all the magic to configure everything)
include( "${wxWidgets_USE_FILE}" )

# For convenience we define the sources as a variable. You can add 
# header files and cpp/c files and CMake will sort them out
set(SRCS src/WxTestApp.cpp src/WxTestFrame.cpp)

add_executable(${CMAKE_PROJECT_NAME} ${SRCS})

target_link_libraries(${CMAKE_PROJECT_NAME} ${wxWidgets_LIBRARIES})

IF (APPLE)
  set(BININSTDIR "${PROJECT_NAME}.app/Contents/MacOS")
  SET(RPATH_PREFIX "@executable_path")
ELSE()
  set(BININSTDIR "bin")
  IF (WIN32)
    SET(LIBINSTDIR "bin")
  ELSE ()
    SET(LIBINSTDIR "lib" CACHE STRING "library directory")
  ENDIF ()
ENDIF()

install(TARGETS ${CMAKE_PROJECT_NAME} RUNTIME DESTINATION "${BININSTDIR}")

set(CPACK_STRIP_FILES ON)
set(CPACK_PACKAGE_CONTACT "osamarin68@gmail.com")

if (APPLE)
  set (CPACK_GENERATOR DragNDrop)
elseif (WIN32)
  set (CPACK_GENERATOR ZIP NSIS)
elseif(${CMAKE_SYSTEM_NAME} MATCHES "Linux")
  set(CPACK_GENERATOR TGZ RPM DEB)
endif()

include(CPack)
