// generated from rosidl_generator_dds_idl/resource/idl.idl.em
// with input from @(package_name):@(interface_path)
// generated code does not contain a copyright notice
@{
import os
from rosidl_parser.definition import Include
includes = content.get_elements_of_type(Include)
}@
@[if includes]@

@[  for include in includes]@
@{
name, ext = os.path.splitext(include.locator)
dir_name = os.path.dirname(name)
include_name = '{}_{}'.format(os.path.join(dir_name, *subfolders, os.path.basename(name)), ext)
}@
#include "@(include_name)"
@[  end for]@
@[end if]@
@{
from rosidl_parser.definition import Action
from rosidl_parser.definition import Message
from rosidl_parser.definition import Service

for message in content.get_elements_of_type(Message):
    TEMPLATE(
        'msg.idl.em', package_name=package_name,
        interface_path=interface_path, message=message,
        get_post_struct_lines=get_post_struct_lines
    )

for service in content.get_elements_of_type(Service):
    TEMPLATE(
        'srv.idl.em', package_name=package_name,
        interface_path=interface_path, service=service
    )

for action in content.get_elements_of_type(Action):
    TEMPLATE(
        'action.idl.em', package_name=package_name,
        interface_path=interface_path, action=action
    )
}@
