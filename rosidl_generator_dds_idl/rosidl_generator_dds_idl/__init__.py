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

from rosidl_cmake import generate_files
from rosidl_parser import BaseType
from rosidl_parser import BaseString
from rosidl_parser import BasicType
from rosidl_parser import NamespacedType
from rosidl_parser import String
from rosidl_parser import WString


def generate_dds_idl(generator_arguments_file):
    mapping = {
        'idl.idl.em': '%s.idl'
    }
    functions = {
        'idl_typename': idl_typename,
        'idl_literal': idl_literal
    }
    generate_files(generator_arguments_file, mapping, functions)
    return 0


# used by the template
def idl_typename(type_):
    assert(isinstance(type_, BaseType))
    if isinstance(type_, BasicType):
        typename = type_.type
    elif isinstance(type_, BaseString):
        if isinstance(type_, String):
            typename = 'string'
        elif isinstance(type_, WString):
            typename = 'wstring'
        else:
            assert False, 'Unknown string type'
        if type_.maximum_size is not None:
            typename += '<%d>' % (type_.maximum_size)
    elif isinstance(type_, NamespacedType):
        typename = '::'.join(type_.namespaces + ['dds_', type_.name + '_'])
    else:
        assert False, 'Unknown base type'
    return typename


def idl_literal(type_, value):
    assert(isinstance(type_, BaseType))
    if isinstance(type_, BasicType):
        if type_.type == 'boolean':
            literal = '''TRUE''' if value else '''FALSE'''
        elif type_.type == 'char':
            literal = '''%s''' % value
        elif type_.type in ('float', 'double'):
            literal = '%f' % value
        else:
            literal = '%d' % value
    elif isinstance(type_, String):
        literal = '"%s"' % value
    elif isinstance(type_, WString):
        literal = 'L"%s"' % value
    else:
        assert False, 'Unknown base type'
    return literal
