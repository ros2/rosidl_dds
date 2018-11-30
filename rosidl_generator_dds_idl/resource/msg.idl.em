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
@[  for constant in message.constants]@
const @(idl_base_type(constant.type)) @(constant.name) = @(idl_literal(constant.value));
@[  end for]
}
@[end if]@

struct @(message.structure.type.name)_ {
@[for member in message.structure.members]@
@[  if isinstance(member.type, NestedType)]@
@[    if isinstance(member.type, Array)]@
@(idl_base_type(member.type.basetype)) @(member.name)[@(member.type.size)];
@[    elif isinstance(member.type, Sequence)]@
sequence<@(idl_base_type(member.type.basetype))@
@[      if isinstance(member.type, BoundedSequence)]@
, @(member.type.upper_bound)@
@[      end if]@
> @(member.name);
@(member.name)[@(member.type.size)];
@[    else]@

@[    end if]
@[  elif isinstance(member.type, BaseType)]@
@(idl_typename(member.type)) @(member.name);
@[  else]@

@[  end if]@
@[end for]@

};

};  // module dds_

@[for ns in reversed(message.structure.type.namespaces)]@
};  // module @(ns) {

@[end for]@