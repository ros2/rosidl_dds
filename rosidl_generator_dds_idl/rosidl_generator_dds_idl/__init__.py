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

import os

from rosidl_cmake import expand_template
from rosidl_cmake import get_newest_modification_time
from rosidl_cmake import read_generator_arguments
from rosidl_parser.definition import IdlLocator
from rosidl_parser.parser import parse_idl_file


def convert_dds_idl(generator_arguments_file, subfolders, extension_module_name):
    args = read_generator_arguments(generator_arguments_file)

    template_file = os.path.join(args['template_dir'], 'idl.idl.em')
    assert os.path.exists(template_file), \
        "The template '%s' does not exist" % template_file

    # look for extensions for the default functions
    # TODO: update as needed
    functions = {
        'get_include_directives': get_include_directives,
        'get_post_struct_lines': get_post_struct_lines,
        'msg_type_to_idl': msg_type_to_idl,
    }
    if extension_module_name is not None:
        pkg = __import__(extension_module_name)
        module_name = extension_module_name.rsplit('.', 1)[1]
        if hasattr(pkg, module_name):
            module = getattr(pkg, module_name)
            for function_name in functions.keys():
                if hasattr(module, function_name):
                    functions[function_name] = \
                        getattr(module, function_name)

    latest_target_timestamp = get_newest_modification_time(args['target_dependencies'])

    for idl_tuples in args.get('idl_tuples', []):
        idl_parts = idl_tuple.rsplit(':', 1)
        assert len(idl_parts) == 2

        locator = IdlLocator(*idl_parts)
        idl_rel_path = pathlib.Path(idl_parts[1])
        try:
            idl_file = parse_idl_file(
                locator, png_file=os.path.join(
                    args['output_dir'], str(idl_rel_path.parent),
                    idl_rel_path.stem) + '.png')

            generated_file = os.path.join(
                args['output_dir'], str(idl_rel_path.parent),
                generated_filename %
                convert_camel_case_to_lower_case_underscore(idl_rel_path.stem))
            data = {
                'package_name': args['package_name'],
                'interface_path': idl_rel_path,
                'content': idl_file.content
            }
            data.update(functions)

            expand_template(
                os.path.basename(template_file), data,
                generated_file, minimum_timestamp=latest_target_timestamp,
                template_basepath=template_basepath)

        except Exception as e:
            print(
                'Error processing idl file: ' +
                str(locator.get_absolute_path()), file=sys.stderr)
            raise(e)
    return 0


MSG_TYPE_TO_IDL = {
    'bool': 'boolean',
    'byte': 'octet',
    'char': 'char',
    'int8': 'octet',
    'uint8': 'octet',
    'int16': 'short',
    'uint16': 'unsigned short',
    'int32': 'long',
    'uint32': 'unsigned long',
    'int64': 'long long',
    'uint64': 'unsigned long long',
    'float32': 'float',
    'float64': 'double',
    'string': 'string',
}


# used by the template
def get_include_directives(spec, subfolders):
    include_directives = set()
    for field in spec.fields:
        if field.type.is_primitive_type():
            continue
        include_directive = '#include "%s/%s_.idl"' % \
            ('/'.join([field.type.pkg_name] + subfolders), field.type.type)
        include_directives.add(include_directive)
    return sorted(include_directives)


# used by the template
def get_post_struct_lines(spec):
    return []


# used by the template
def msg_type_to_idl(type_, ns):
    """
    Convert a message type into the DDS declaration.

    Example input: uint32, std_msgs/String
    Example output: uint32_t, std_msgs::String_<ContainerAllocator>

    @param type: The message type
    @type type: rosidl_parser.Type
    """
    string_upper_bound = None
    if type_.is_primitive_type():
        idl_type = MSG_TYPE_TO_IDL[type_.type]
        if type_.type == 'string' and type_.string_upper_bound is not None:
            string_upper_bound = type_.string_upper_bound
    else:
        idl_type = '%s::%s::dds_::%s_' % (type_.pkg_name, ns, type_.type)
    return _msg_type_to_idl(type_, idl_type, string_upper_bound=string_upper_bound)


def _msg_type_to_idl(type_, idl_type, string_upper_bound=None):
    if type_.is_array:
        if type_.array_size is None or type_.is_upper_bound:
            sequence_type = idl_type
            if string_upper_bound is not None:
                sequence_type += '<%s>' % string_upper_bound
            if type_.is_upper_bound:
                sequence_type += ', %u' % type_.array_size
            return [
                '', '',
                'sequence<%s%s>' % (sequence_type, ' ' if sequence_type.endswith('>') else '')]
        else:
            typename = '%s_array_%s' % \
                (idl_type.replace(' ', '_').replace('::', '__'), type_.array_size)
            return [
                'typedef %s' % idl_type,
                '%s[%s];' % (typename, type_.array_size),
                '%s' % typename
            ]
    elif type_.string_upper_bound is not None and \
            type_.is_primitive_type() and type_.type == 'string':
        return ['', '', '%s<%u>' % (idl_type, type_.string_upper_bound)]
    else:
        return ['', '', idl_type]
