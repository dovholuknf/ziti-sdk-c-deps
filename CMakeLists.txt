cmake_minimum_required(VERSION 3.21)
project(ziti-sdk-c-deps C CXX)

set(ZITI_SDK_VERSION "1.20.1" CACHE STRING "ziti-sdk-c tag or branch")

include(FetchContent)
FetchContent_Declare(ziti-sdk-c
        GIT_REPOSITORY https://github.com/openziti/ziti-sdk-c.git
        GIT_TAG ${ZITI_SDK_VERSION})
set(ZITI_BUILD_TESTS off)
set(ZITI_BUILD_PROGRAMS off)
set(BUILD_TESTING off)
set(BUILD_EXAMPLES off)
FetchContent_MakeAvailable(ziti-sdk-c)
