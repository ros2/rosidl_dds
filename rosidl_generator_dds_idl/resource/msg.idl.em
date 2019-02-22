@# Included from rosidl_generator_dds_idl/resource/idl.idl.em
@{
from rosidl_generator_dds_idl import idl_typename, idl_literal

from rosidl_parser.definition import Array
from rosidl_parser.definition import BaseType
from rosidl_parser.definition import BoundedSequence
from rosidl_parser.definition import CONSTANT_MODULE_SUFFIX
from rosidl_parser.definition import NestedType
from rosidl_parser.definition import Sequence

}@

@[for ns in message.structure.type.namespaces]@
module @(ns) {

@[end for]@
module dds_ {

@[if message.constants]@
module @(message.structure.type.name)@(CONSTANT_MODULE_SUFFIX) {
@[  for constant in message.constants.values()]@
const @(idl_typename(constant.type)) @(constant.name)_ = @(idl_literal(constant.type, constant.value));
@[  end for]
};
@[end if]@

struct @(message.structure.type.name)_ {
@[for member in message.structure.members]@
@[  for value in member.get_annotation_values('key')]@
@@key@
@[    if value]@
("@(value)")@
@[    end if]
@[  end for]@
@[  if isinstance(member.type, NestedType)]@
@[    if isinstance(member.type, Array)]@
@(idl_typename(member.type.basetype)) @(member.name)_[@(member.type.size)];
@[    elif isinstance(member.type, Sequence)]@
sequence<@(idl_typename(member.type.basetype))@
@[      if isinstance(member.type, BoundedSequence)]@
, @(member.type.upper_bound)@
@[      elif idl_typename(member.type.basetype).endswith('>')]@
 @
@[      end if]@
> @(member.name)_;
@[    else]@

@[    end if]
@[  elif isinstance(member.type, BaseType)]@
@(idl_typename(member.type)) @(member.name)_;
@[  else]@

@[  end if]@
@[end for]@

};

@[for line in get_post_struct_lines(message)]@
@(line)
@[end for]@

};  // module dds_

@[for ns in reversed(message.structure.type.namespaces)]@
};  // module @(ns)

@[end for]@
