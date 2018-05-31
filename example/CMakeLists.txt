cmake_minimum_required(VERSION 3.1.0)
project(DezyneCMakeExample CXX)
set(CMAKE_CXX_STANDARD 11)

include(${CMAKE_CURRENT_SOURCE_DIR}/../Dezyne.cmake)
dezyne_download_runtime()

set(SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/src")
set(MODELS_DIR "${CMAKE_CURRENT_SOURCE_DIR}/models")

include_directories(${DEZYNE_RUNTIME_HEADERS_DIR} ${SOURCE_DIR})

set(SOURCES "${SOURCE_DIR}/main.cc"
            "${SOURCE_DIR}/Led.cc")

set(HEADERS "${SOURCE_DIR}/Led.hh")

set(MODELS "${MODELS_DIR}/system.dzn"
           "${MODELS_DIR}/controller.dzn"
           "${MODELS_DIR}/led.dzn")


add_executable(${PROJECT_NAME} ${SOURCES} ${HEADERS})
dezyne_target_models(${PROJECT_NAME} "${MODELS}")
