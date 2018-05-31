# Copyright 2018 Martijn Stommels
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.



set(DEZYNE_DIR "${CMAKE_BINARY_DIR}/dezyne")
set(DEZYNE_RUNTIME_DIR "${DEZYNE_DIR}/runtime")
set(DEZYNE_RUNTIME_HEADERS_DIR "${DEZYNE_RUNTIME_DIR}/include")
set(DEZYNE_RUNTIME_SOURCE_DIR "${DEZYNE_RUNTIME_DIR}/source")
set(DEZYNE_GENERATED_DIR "${DEZYNE_DIR}/generated")
set(DEZYNE_BIN_DIR "${DEZYNE_DIR}/bin")

# Store the location of the Dezyne.cmake file
# since the context of when the function is run is different
set(DEZYNE_MODULE_DIR ${CMAKE_CURRENT_LIST_DIR})
          
set(DEZYNE_VERSION "2.7.0")

# TODO: add arguments to select runtime language and version
function(dezyne_download_runtime)
  execute_process(COMMAND dzn ls -R /share/runtime/c++
    RESULT_VARIABLE _ls_result
    OUTPUT_VARIABLE _ls
    TIMEOUT 10)

  if(NOT _ls_result EQUAL 0)
    message(FATAL_ERROR "Failed to request runtime files")
  endif()

  file(MAKE_DIRECTORY ${DEZYNE_RUNTIME_HEADERS_DIR})
  file(MAKE_DIRECTORY ${DEZYNE_RUNTIME_HEADERS_DIR}/dzn)
  file(MAKE_DIRECTORY ${DEZYNE_RUNTIME_SOURCE_DIR})

  # split on each new line
  string(REGEX MATCHALL "[^\r?\n]*\r?\n"
         _ls_lines ${_ls})

  foreach(line IN LISTS _ls_lines)
    string(STRIP ${line} _lineStripped)

    if(${_lineStripped} MATCHES ".+\.cc|hh$")
      string(REGEX MATCH "(c\\+\\+)/(.+)" _serverfile ${_lineStripped})
      set(_file ${CMAKE_MATCH_2})

      if(${_lineStripped} MATCHES ".+\.hh$")
        set(_file_path ${DEZYNE_RUNTIME_HEADERS_DIR}/${_file})
      elseif(${_lineStripped} MATCHES ".+\.cc$")
         set(_file_path ${DEZYNE_RUNTIME_SOURCE_DIR}/${_file})
       endif()

      add_custom_command(OUTPUT ${_file_path}
        COMMAND dzn cat --version=${DEZYNE_VERSION} /share/runtime/${_serverfile} > ${_file_path}
        VERBATIM)
       list(APPEND DEZYNE_RUNTIME_HEADERS ${_file_path})
     endif()

  endforeach()

  add_library(dezyne_runtime STATIC ${DEZYNE_RUNTIME_SOURCE} ${DEZYNE_RUNTIME_HEADERS})
  target_link_libraries(dezyne_runtime pthread)
  target_include_directories(dezyne_runtime PRIVATE ${DEZYNE_RUNTIME_HEADERS_DIR})
  target_compile_options(dezyne_runtime PRIVATE "-std=c++11")

endfunction(dezyne_download_runtime)

function(dezyne_target_models target models)

  message(STATUS "name: ${target}")
  message(STATUS "model files: ${models}")

  set("${target}_GENERATED" "${DEZYNE_GENERATED_DIR}/${name}")
  file(MAKE_DIRECTORY ${${target}_GENERATED})

  foreach(model IN LISTS models)

    get_filename_component(file_name ${model} NAME)

    set(generated_target "generate_${target}_${file_name}")
    message(STATUS "Generating: ${generated_target}")

    # TODO: not great, since this is run on configuration time and thus every time cmake is run
    execute_process(COMMAND dzn code --version=${DEZYNE_VERSION} -l c++ ${model} -o ${${target}_GENERATED} --depends=.d
      RESULT_VARIABLE generated_result
      OUTPUT_VARIABLE generated_output
      TIMEOUT 10)

    if(NOT generated_result EQUAL 0)
      message(FATAL_ERROR "Failed to generate files for ${model}")
    endif()
  endforeach()


  file(GLOB sources "${${target}_GENERATED}/*.cc")
  file(GLOB headers "${${target}_GENERATED}/*.hh")

  target_sources(${target} PUBLIC ${sources} ${headers})
  target_include_directories(${target} PUBLIC ${${target}_GENERATED})
  target_link_libraries(${target} dezyne_runtime)

endfunction(dezyne_target_models)
