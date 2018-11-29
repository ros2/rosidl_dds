// generated from rosidl_generator_dds_idl/resource/idl.idl.em
// with input from @(package_name):@(interface_path)
// generated code does not contain a copyright notice
@{
from rosidl_parser.definition import Include
for includes in content.get_elements_of_type(Include):
}@
@[if includes]@

@[  for include in includes]@
#include "@(include.locator)"
@[  end for]@
@[end if]@
@{
from rosidl_parser.definition import Message
}@
@[for message in content.get_elements_of_type(Message)]@

@(TEMPLATE('msg.idl.em', message=message))@
@[end for]@
@{
from rosidl_parser.definition import Service
}@
@[for service in content.get_elements_of_type(Service)]@

@(TEMPLATE('srv.idl.em', service=service))@
@[end for]@
@{
from rosidl_parser.definition import Action
}@
@[for action in content.get_elements_of_type(Action)]@

@(TEMPLATE('action.idl.em', action=action))@
@[end for]@
