# Copyright 2014-2015 Open Source Robotics Foundation, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#
# Generate DDS IDL files from ROS IDL files.
#
# :param target: the name of the generation target,
# :type target: string
# :param IDL_FILES: a list of ROS interface files
# :type IDL_FILES: list of strings
# :param DEPENDENCY_PACKAGE_NAMES: a list of dependency package names
# :type DEPENDENCY_PACKAGE_NAMES: list of strings
# :param OUTPUT_SUBFOLDERS: a list of subfolders between the package name and
#   the interface name
# :type OUTPUT_SUBFOLDERS: optional list of strings
# :param EXTENSION: a Python module extending the generator
# :type EXTENSION: optional string
#
# @public
#
macro(rosidl_generate_dds_interfaces target)
  cmake_parse_arguments(_ARG "" "EXTENSION"
    "IDL_FILES;DEPENDENCY_PACKAGE_NAMES;OUTPUT_SUBFOLDERS" ${ARGN})
  if(_ARG_UNPARSED_ARGUMENTS)
    message(FATAL_ERROR "rosidl_generate_dds_interfaces() called with "
      "unused arguments: ${_ARG_UNPARSED_ARGUMENTS}")
  endif()

  set(_output_basepath "${CMAKE_CURRENT_BINARY_DIR}/rosidl_generator_dds_idl/${PROJECT_NAME}")
  set(_generated_msg_files "")
  set(_generated_srv_files "")
  set(_generated_action_files "")
  foreach(_idl_file ${_ARG_IDL_FILES})
    get_filename_component(_extension "${_idl_file}" EXT)
    get_filename_component(_parent_folder "${_idl_file}" DIRECTORY)
    get_filename_component(_parent_folder "${_parent_folder}" NAME)
    set(_output_path "${_output_basepath}/${_parent_folder}")
    foreach(_subfolder ${_ARG_OUTPUT_SUBFOLDERS})
      set(_output_path "${_output_path}/${_subfolder}")
    endforeach()
    get_filename_component(_name "${_idl_file}" NAME_WE)
    if(_extension STREQUAL ".msg")
      set(_allowed_parent_folders "msg" "srv" "action")
      if(NOT _parent_folder IN_LIST _allowed_parent_folders)
        message(FATAL_ERROR "Interface file with unknown parent folder: ${_idl_file}")
      endif()
      set(_generated_files "_generated_${_parent_folder}_files")
      list(APPEND ${_generated_files} "${_output_path}/${_name}_.idl")
    elseif(_extension STREQUAL ".srv")
      # TODO(dirk-thomas) this is only done for opensplice
      # and should be move to the opensplice specific generator package
      set(_allowed_parent_folders "srv" "action")
      if(NOT _parent_folder IN_LIST _allowed_parent_folders)
        message(FATAL_ERROR "Interface file with unknown parent folder: ${_idl_file}")
      endif()
      set(_generated_files "_generated_${_parent_folder}_files")
      list(APPEND ${_generated_files} "${_output_path}/Sample_${_name}_Request_.idl")
      list(APPEND ${_generated_files} "${_output_path}/Sample_${_name}_Response_.idl")
    else()
      message(FATAL_ERROR "Interface file with unknown extension: ${_idl_file}")
    endif()
  endforeach()

  set(_dependency_files "")
  set(_dependencies "")
  foreach(_pkg_name ${_ARG_DEPENDENCY_PACKAGE_NAMES})
    foreach(_idl_file ${${_pkg_name}_INTERFACE_FILES})
      set(_abs_idl_file "${${_pkg_name}_DIR}/../${_idl_file}")
      normalize_path(_abs_idl_file "${_abs_idl_file}")
      list(APPEND _dependency_files "${_abs_idl_file}")
      list(APPEND _dependencies "${_pkg_name}:${_abs_idl_file}")
    endforeach()
  endforeach()


  set(target_dependencies
    "${rosidl_generator_dds_idl_BIN}"
    ${rosidl_generator_dds_idl_GENERATOR_FILES}
    "${rosidl_generator_dds_idl_TEMPLATE_DIR}/msg.idl.em"
    ${rosidl_generate_interfaces_IDL_FILES}
    ${_dependency_files})
  foreach(dep ${target_dependencies})
    if(NOT EXISTS "${dep}")
      get_property(is_generated SOURCE "${dep}" PROPERTY GENERATED)
      if(NOT ${_is_generated})
        message(FATAL_ERROR "Target dependency '${dep}' does not exist")
      endif()
    endif()
  endforeach()

  # use unique arguments file for each subfolder
  set(generator_arguments_file "${CMAKE_CURRENT_BINARY_DIR}/rosidl_generator_dds_idl_")
  foreach(_subfolder ${_ARG_OUTPUT_SUBFOLDERS})
    set(generator_arguments_file "${generator_arguments_file}_${_subfolder}_")
  endforeach()
  set(generator_arguments_file "${generator_arguments_file}_arguments.json")
  rosidl_write_generator_arguments(
    "${generator_arguments_file}"
    PACKAGE_NAME "${PROJECT_NAME}"
    ROS_INTERFACE_FILES "${_ARG_IDL_FILES}"
    ROS_INTERFACE_DEPENDENCIES "${_dependencies}"
    OUTPUT_DIR "${_output_basepath}"
    TEMPLATE_DIR "${rosidl_generator_dds_idl_TEMPLATE_DIR}"
    TARGET_DEPENDENCIES ${target_dependencies}
  )

  add_custom_command(
    OUTPUT ${_generated_msg_files} ${_generated_srv_files} ${_generated_action_files}
    COMMAND ${PYTHON_EXECUTABLE} ${rosidl_generator_dds_idl_BIN}
    --generator-arguments-file "${generator_arguments_file}"
    --subfolders ${_ARG_OUTPUT_SUBFOLDERS}
    --extension ${_ARG_EXTENSION}
    DEPENDS ${target_dependencies}
    COMMENT "Generating DDS interfaces"
    VERBATIM
  )

  add_custom_target(
    ${target}
    DEPENDS
    ${_generated_msg_files} ${_generated_srv_files} ${_generated_action_files}
  )

  set(_msg_destination "share/${PROJECT_NAME}/msg")
  set(_srv_destination "share/${PROJECT_NAME}/srv")
  set(_action_destination "share/${PROJECT_NAME}/action")
  foreach(_subfolder ${_ARG_OUTPUT_SUBFOLDERS})
    set(_msg_destination "${_msg_destination}/${_subfolder}")
    set(_srv_destination "${_srv_destination}/${_subfolder}")
    set(_action_destination "${_action_destination}/${_subfolder}")
  endforeach()
  if(NOT rosidl_generate_interfaces_SKIP_INSTALL)
    if(NOT _generated_msg_files STREQUAL "")
      install(
        FILES ${_generated_msg_files}
        DESTINATION "${_msg_destination}"
      )
    endif()
    if(NOT _generated_srv_files STREQUAL "")
      install(
        FILES ${_generated_srv_files}
        DESTINATION "${_srv_destination}"
      )
    endif()
    if(NOT _generated_action_files STREQUAL "")
      install(
        FILES ${_generated_action_files}
        DESTINATION "${_action_destination}"
      )
    endif()
  endif()
endmacro()
