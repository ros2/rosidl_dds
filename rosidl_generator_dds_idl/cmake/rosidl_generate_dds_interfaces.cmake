# include CMake functions
include(CMakeParseArguments)

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
  #message(" - rosidl_generate_dds_interfaces(${target} ${ARGN})")

  cmake_parse_arguments(_ARG "" "EXTENSION"
    "IDL_FILES;DEPENDENCY_PACKAGE_NAMES;OUTPUT_SUBFOLDERS" ${ARGN})
  if(_ARG_UNPARSED_ARGUMENTS)
    message(FATAL_ERROR "rosidl_generate_dds_interfaces() called with "
      "unused arguments: ${_ARG_UNPARSED_ARGUMENTS}")
  endif()

  message("   - target: ${target}")
  message("   - interface files: ${_ARG_IDL_FILES}")
  message("   - dependency package names: ${_ARG_DEPENDENCY_PACKAGE_NAMES}")
  message("   - output subfolders: ${_ARG_OUTPUT_SUBFOLDERS}")

  set(_output_path "${CMAKE_CURRENT_BINARY_DIR}/rosidl_generator_dds_idl/${PROJECT_NAME}")
  foreach(_subfolder ${_ARG_OUTPUT_SUBFOLDERS})
    set(_output_path "${_output_path}/${_subfolder}")
  endforeach()
  set(_generated_files "")
  foreach(_idl_file ${_ARG_IDL_FILES})
    get_filename_component(name "${_idl_file}" NAME_WE)
    list(APPEND _generated_files "${_output_path}/${name}_.idl")
  endforeach()

  set(_dependency_files "")
  set(_dependencies "")
  foreach(_pkg_name ${_ARG_DEPENDENCY_PACKAGE_NAMES})
    foreach(_idl_file ${${_pkg_name}_INTERFACE_FILES})
      set(_abs_idl_file "${${_pkg_name}_DIR}/../${_idl_file}")
      list(APPEND _dependency_files "${_abs_idl_file}")
      list(APPEND _dependencies "${_pkg_name}:${_abs_idl_file}")
    endforeach()
  endforeach()

  message("   - generated files: ${_generated_files}")
  message("   - dependencies: ${_dependencies}")

  # TODO either pass space separated argument lists or split them in Python
  add_custom_command(
    OUTPUT ${_generated_files}
    COMMAND ${PYTHON_EXECUTABLE} ${rosidl_generator_dds_idl_BIN}
    --pkg-name ${PROJECT_NAME}
    --ros-interface-files ${_ARG_IDL_FILES}
    --deps ${_dependencies}
    --output-dir ${_output_path}
    --template-dir ${rosidl_generator_dds_idl_TEMPLATE_DIR}
    --subfolders ${_ARG_OUTPUT_SUBFOLDERS}
    --extension ${_ARG_EXTENSION}
    DEPENDS
    ${rosidl_generator_dds_idl_BIN}
    ${rosidl_generator_dds_idl_DIR}/../../../${PYTHON_INSTALL_DIR}/rosidl_generator_dds_idl/__init__.py
    ${rosidl_generator_dds_idl_TEMPLATE_DIR}/msg.idl.template
    ${_ARG_IDL_FILES}
    ${_dependency_files}
    COMMENT "Generating DDS interfaces"
    VERBATIM
  )

  add_custom_target(
    ${target}
    DEPENDS
    ${_generated_files}
  )

  set(_destination "share/${PROJECT_NAME}")
  foreach(_subfolder ${_ARG_OUTPUT_SUBFOLDERS})
    set(_destination "${_destination}/${_subfolder}")
  endforeach()
  install(
    FILES ${_generated_files}
    DESTINATION "${_destination}"
  )
endmacro()
