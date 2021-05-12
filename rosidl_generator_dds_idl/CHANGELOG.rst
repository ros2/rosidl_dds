^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Changelog for package rosidl_generator_dds_idl
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Forthcoming
-----------

0.8.0 (2021-03-19)
------------------
* Expose .idl to DDS .idl conversion via rosidl translate CLI (`#55 <https://github.com/ros2/rosidl_dds/issues/55>`_)
* Update maintainers (`#54 <https://github.com/ros2/rosidl_dds/issues/54>`_)
  Previous: @dirk-thomas
  New: @sloretz
* Contributors: Michel Hidalgo, Shane Loretz

0.7.1 (2019-05-08)
------------------
* 0.7.1
* fix customization hooks (`#51 <https://github.com/ros2/rosidl_dds/issues/51>`_)
* simplify code using updated definition API (`#50 <https://github.com/ros2/rosidl_dds/issues/50>`_)
* update code to match refactoring of rosidl definitions (`#49 <https://github.com/ros2/rosidl_dds/issues/49>`_)
* Contributors: Dirk Thomas, Michael Carroll

0.7.0 (2019-04-12)
------------------
* change generator to IDL-based pipeline (`#47 <https://github.com/ros2/rosidl_dds/issues/47>`_)
  * sketch of idl2idl templates
  * invoke idl2idl template
  * Update rosidl_generate_dds_interfaces to accept tuples of IDL files to convert
  * Updates IDL templates for messages.
  * Ok
  * Fixes
  * Allow context to be extended and add optional 'post-struct line generation'
  * Add trailing underscores to struct member names
  * Add header guards
  * Refactor idl.idl.em
  * Propagates variables to nested templates.
  * Fixes bad indentation in templates.
  * Propagates yet more variables.
  * Fixes installation paths for IDL files.
  * Moves header guards one template level up.
  * Add wrapper_msg.idl.em
  * Fixes bad install macro call.
  * Rename variable for Service object to 'service'
  * Add message templates for user-defined components of actions
  * Pass in service wrapper templates rather than having them here
  * Always use slashes in IDL include paths.
  * Add missing check when converting negative int8 values to octet
  * Avoid duplicate include directives.
  * Add underscore suffix to constants
  * add space between two >
  * Removes backup srv IDL template.
  * fix linter warnings
  * fix double slash
  * Remove extra brace in namespace comment
  * match renamed action types
  * remove usage of unset variable
  * pass through key annotations
  * Update rosidl_generator_dds_idl/bin/rosidl_generator_dds_idl
  Co-Authored-By: dirk-thomas <dirk-thomas@users.noreply.github.com>
  * Update rosidl_generator_dds_idl/bin/rosidl_generator_dds_idl
  Co-Authored-By: dirk-thomas <dirk-thomas@users.noreply.github.com>
  * document SERVICE_TEMPLATES
  * fix wrong variable name
  * readd explicit dependency on absolute paths of idl files
  * declare missing dependency on additional templates
* Contributors: Jacob Perron

0.6.0 (2018-11-15)
------------------
* Allow generated IDL files (`#45 <https://github.com/ros2/rosidl_dds/issues/45>`_)
* Merge pull request `#44 <https://github.com/ros2/rosidl_dds/issues/44>`_ from ros2/hidmic/prepare_for_action_generation
  Support service generation on action folders
* Fixes CMake lint issues.
* Removes remaininig srv folder assumptions.
* Makes rosidl interfaces generation action folder aware.
* Contributors: Alexis Pojomovsky, Michel Hidalgo, Shane Loretz

0.5.0 (2018-06-23)
------------------
* use CMAKE_CURRENT_BINARY_DIR for arguments json (`#42 <https://github.com/ros2/rosidl_dds/issues/42>`_)
* Contributors: Dirk Thomas

0.4.0 (2017-12-08)
------------------
* 0.0.3
* Merge pull request `#41 <https://github.com/ros2/rosidl_dds/issues/41>`_ from ros2/flake8_plugins
  update style to satisfy new flake8 plugins
* update style to satisfy new flake8 plugins
* 0.0.2
* fix spelling in docblock
* Comply with flake8 + flake8-import-order linters (`#40 <https://github.com/ros2/rosidl_dds/issues/40>`_)
* Merge pull request `#39 <https://github.com/ros2/rosidl_dds/issues/39>`_ from ros2/remove_include
  remove unnecessary include
* remove unnecessary include
* support sequences of upper bounded strings (`#38 <https://github.com/ros2/rosidl_dds/issues/38>`_)
  * Added support for bounded string idl_types within bounded sequences.
  * minor code updates
  * fix issue with unbounded sequence
* update schema url
* add schema to manifest files
* Merge pull request `#35 <https://github.com/ros2/rosidl_dds/issues/35>`_ from ros2/cmake35
  require CMake 3.5
* remove trailing spaces from comparisons, obsolete quotes and explicit variable expansion
* require CMake 3.5
* Merge pull request `#34 <https://github.com/ros2/rosidl_dds/issues/34>`_ from ros2/template2em
  change .template into .em
* change .template into .em
* Merge pull request `#33 <https://github.com/ros2/rosidl_dds/issues/33>`_ from ros2/ctest_build_testing
  use CTest BUILD_TESTING
* use CTest BUILD_TESTING
* Merge pull request `#32 <https://github.com/ros2/rosidl_dds/issues/32>`_ from ros2/indent_template_logic
  update indentation of template logic
* update indentation of template logic
* Merge pull request `#30 <https://github.com/ros2/rosidl_dds/issues/30>`_ from ros2/c_api
  change constant member to allow reuse of other functions using the type
* change constant member to allow reuse of other functions using the type
* change ifder to match filename
* add explicit build type
* Merge pull request `#26 <https://github.com/ros2/rosidl_dds/issues/26>`_ from ros2/fix_skip_install
  fix SKIP_INSTALL to affect generated files
* fix SKIP_INSTALL to affect generated files
* Merge pull request `#24 <https://github.com/ros2/rosidl_dds/issues/24>`_ from ros2/fix_and_unify_generators
  refactor generators, fix timestamp of generated files
* refactor generators, fix timestamp of generated files
* fix style
* fix assert
* Merge pull request `#22 <https://github.com/ros2/rosidl_dds/issues/22>`_ from ros2/fix_non_primitive_static_arrays
  fix generated idl for static arrays of non-primitive types
* fix generated idl for static arrays of non-primitive types
* Merge pull request `#20 <https://github.com/ros2/rosidl_dds/issues/20>`_ from ros2/refactor_msg_gen
  refactor message generation
* refactor message generation (`ros2/ros2#48 <https://github.com/ros2/ros2/issues/48>`_)
* Merge pull request `#18 <https://github.com/ros2/rosidl_dds/issues/18>`_ from ros2/pragma_hook
  replace hard coded pragma with extension point
* replace hard coded pragma with extension point (fix `#11 <https://github.com/ros2/rosidl_dds/issues/11>`_)
* Merge pull request `#14 <https://github.com/ros2/rosidl_dds/issues/14>`_ from ros2/regenerate_templated_files_only_when_changed
  only rewrite templated files when the content has changed
* only rewrite templated files when the content has changed
* disable debug output
* add missing copyright / license information
* code style only
* Merge pull request `#10 <https://github.com/ros2/rosidl_dds/issues/10>`_ from ros2/opensplice-services
  Use two uint64 as writer guid
* Use two uint64 as writer guid
* Merge pull request `#7 <https://github.com/ros2/rosidl_dds/issues/7>`_ from ros2/srv-idl-generator
  Added support for Request and Response IDL files
* Use msg.idl.template for services messages
* Added client_guid
* Use explicit kwarg
* Symmetric output
* One import per line
* Prefix variable with underscore. Remove duplicated code
* Added support for Request and Response IDL files
* Merge pull request `#6 <https://github.com/ros2/rosidl_dds/issues/6>`_ from ros2/fix_warning
  fix warning from rti code generator
* fix warning from rti code generator
* white space only
* Merge pull request `#2 <https://github.com/ros2/rosidl_dds/issues/2>`_ from ros2/use_ament_lint_auto
  use ament_lint_auto
* use ament_lint_auto
* Merge pull request `#1 <https://github.com/ros2/rosidl_dds/issues/1>`_ from ros2/request_reply
  Added support for services
* Added support for services
* use project(.. NONE)
* consolidate dependencies
* expand PYTHON_INSTALL_DIR at configure time
* use normalize_path()
* allow customizing idl generator
* add constant support
* support upper bounds on arrays and string, support default values for primitive types
* pass upper bound to idl as well as introspection type support
* refactor namespaces / includes for cross implementation communication
* update mapping of primitive types
* support multiple type supports
* add packages which have been moved from other repos
* Contributors: Dirk Thomas, Esteve Fernandez, dhood
