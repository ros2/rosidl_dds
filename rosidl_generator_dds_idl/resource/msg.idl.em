@# Included from rosidl_generator_dds_idl/resource/idl.idl.em
@{
from rosidl_parser.definition import BasicType
from rosidl_parser.definition import BoundedSequence
from rosidl_parser.definition import CONSTANT_MODULE_SUFFIX
from rosidl_parser.definition import NestedType
from rosidl_parser.definition import Sequence
from rosidl_parser.definition import String
}@
@[for ns in messages.structure.type.namespaces]@
module @(ns) {

@[end for]@
module dds_ {

@[if message.constants]@
module @{message.structure.type.name}@@(CONSTANT_MODULE_SUFFIX) {
@[  for constantc in message.constants]@
  @
@[if isinstance(constant.type, BasicType)]@
@(constant.type)@
@[elif isinstance(constant.type, NestedType)]@
XXX array[] need to go behind the constant name though
@[end for]@
 @
@(constant.name)@
 = @
@[    if isinstance(constant.type, BasicType)]@
@[      if constant.type.type == 'boolean']@
@('TRUE' if constant.value else 'FALSE')@
@(constant.value)@
@[      elif constant.type.type == 'char']@
'@(constant.value)'@
@[      else XXX-only-numerics?XXX]@
@[      end for]@
@[    elif isinstance(constant.type, String)]@
"@(constant.value)"
@[    elif isinstance(constant.type, NestedType)]@
XXX array[] need to go behind the constant name though
@[    end for]@
;
@[  end for]@
}
@[end if]@
@[for m in members]@
@[  if isinstance(member.type, BasicType)]@
@(member.type)@
@[  elif isinstance(member.type, Sequence)]@
sequence<@(member.type.basetype)@
@[    if isinstance(member.type, BoundedSequence)]@
, @(member.type.upper_bound)@
@[    end if]@
>@
@[  elif XXX]@
@# XXX typedefs for arrays
XXX@
@[end if]@
 @
@(member.name);
@[end for]@

@##############################################################################
@##############################################################################
@##############################################################################

// generated from rosidl_generator_dds_idl/resource/msg.idl.em

@###############################################
@#
@# ROS interface to DDS interface converter
@#
@# EmPy template for generating <msg>.idl files
@#
@###############################################
@# Start of Template
@#
@# Context:
@#  - spec (rosidl_parser.MessageSpecification)
@#    Parsed specification of the .msg file
@#  - subfolder (string)
@#    The subfolder / subnamespace of the message
@#    Could be 'msg', 'srv' or 'action'
@#  - deps_subfolder (string)
@#    The subfolder / subnamespace of the message dependencies
@#    Could be 'msg', 'srv' or 'action'
@#  - subfolders (list of strings)
@#    The subfolders under the package name
@#    in which the type gets defined which are not part of the namespace
@#  - get_include_directives (function)
@#  - msg_type_to_idl (function)
@###############################################
@
@{
from rosidl_generator_cpp import escape_string
from rosidl_generator_dds_idl import MSG_TYPE_TO_IDL
}@
@
#ifndef __@(spec.base_type.pkg_name)__@(subfolder)__@(spec.base_type.type)__idl__
#define __@(spec.base_type.pkg_name)__@(subfolder)__@(spec.base_type.type)__idl__

@#############################
@# Include dependency messages
@#############################
@[  for line in get_include_directives(spec, [deps_subfolder] + subfolders)]@
@(line)
@[  end for]@

module @(spec.base_type.pkg_name)
{

module @(subfolder)
{

module dds_
{

@##################
@# Define constants
@##################
@# Constants
@[for constant in spec.constants]@
  const @(MSG_TYPE_TO_IDL[constant.type]) @(spec.base_type.type)__@(constant.name) =
@[  if constant.type == 'bool']@
    @('TRUE' if constant.value else 'FALSE');
@[  elif constant.type == 'char']@
    '\@(constant.value)';
@[  elif constant.type == 'int8']@
    @(constant.value if constant.value >= 0 else (constant.value + 256));
@[  elif constant.type == 'string']@
    "@(escape_string(constant.value))";
@[  else]@
    @(constant.value);
@[  end if]@
@[end for]

@{
typedefs = set([])
for field in spec.fields:
  idl_typedef, idl_typedef_var, _ = msg_type_to_idl(field.type, deps_subfolder)
  if idl_typedef and idl_typedef_var and (idl_typedef, idl_typedef_var) not in typedefs:
    print('%s %s__%s__%s' % (idl_typedef, spec.base_type.pkg_name, spec.base_type.type, idl_typedef_var))
    typedefs.add((idl_typedef, idl_typedef_var))
}@

@################################
@# Message struct with all fields
@################################
struct @(spec.base_type.type)_
{

@[if spec.fields]@
@[  for field in spec.fields]@
@{    idl_typedef, idl_typedef_var, idl_type = msg_type_to_idl(field.type, deps_subfolder)}@
@[    if idl_typedef and idl_typedef_var]@
@(      spec.base_type.pkg_name)__@(spec.base_type.type)__@(idl_type) @(field.name)_;
@[    else]@
  @(idl_type) @(field.name)_;
@[    end if]@
@[  end for]@
@[else]@
  boolean _dummy;
@[end if]@

};  // struct @(spec.base_type.type)_

@[for line in get_post_struct_lines(spec)]@
@(line)
@[end for]@

};  // module dds_

};  // module @(subfolder)

};  // module @(spec.base_type.pkg_name)

#endif  // __@(spec.base_type.pkg_name)__@(subfolder)__@(spec.base_type.type)__idl__
