import em
import os

from rosidl_parser import Field
from rosidl_parser import MessageSpecification
from rosidl_parser import Type
from rosidl_parser import parse_message_file
from rosidl_parser import parse_service_file


def generate_dds_idl(
        pkg_name, interface_files, deps, output_dir, template_dir, subfolders,
        extension_module_name):
    template_file_msg = os.path.join(template_dir, 'msg.idl.template')
    assert(os.path.exists(template_file_msg))

    template_file_srv = os.path.join(template_dir, 'srv.idl.template')
    assert(os.path.exists(template_file_srv))

    try:
        os.makedirs(output_dir)
    except FileExistsError:
        pass

    # look for extensions for the default functions
    functions = {
        'get_include_directives': get_include_directives,
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

    for idl_file in interface_files:
        filename, extension = os.path.splitext(idl_file)
        if extension == '.msg':
            spec = parse_message_file(pkg_name, idl_file)
            generated_file = os.path.join(output_dir,
                                          '%s_.idl' % spec.base_type.type)
            print('Generating MESSAGE: %s' % generated_file)

            try:
                # TODO only touch generated file if its content actually changes
                ofile = open(generated_file, 'w')
                data = {'spec': spec, 'subfolders': subfolders}
                data.update(functions)
                # TODO reuse interpreter
                interpreter = em.Interpreter(
                    output=ofile,
                    options={
                        em.RAW_OPT: True,
                        em.BUFFERED_OPT: True,
                    },
                    globals=data,
                )
                interpreter.file(open(template_file_msg))
                interpreter.shutdown()
            except Exception:
                os.remove(generated_file)
                raise
        elif extension == '.srv':
            srv_spec = parse_service_file(pkg_name, idl_file)
            default_value_string = None
            request_fields = [
                Field(
                    Type('int64', context_package_name=pkg_name),
                    'sequence_id', default_value_string),
                Field(
                    Type('%sRequest' % srv_spec.srv_name, context_package_name=pkg_name),
                    'request', default_value_string)
                ]
            response_fields = [
                Field(
                    Type('int64', context_package_name=pkg_name),
                    'sequence_id', default_value_string),
                Field(
                    Type('%sResponse' % srv_spec.srv_name, context_package_name=pkg_name),
                    'response', default_value_string)
                ]
            constants = []
            sample_spec_request = MessageSpecification(
                srv_spec.pkg_name, 'Sample%sRequest' % srv_spec.srv_name, request_fields, constants)
            write_sample_spec_request = MessageSpecification(
                srv_spec.pkg_name, 'WriteSample%sRequest' % srv_spec.srv_name, request_fields,
                constants)

            sample_spec_response = MessageSpecification(
                srv_spec.pkg_name, 'Sample%sResponse' % srv_spec.srv_name, response_fields, constants)
            write_sample_spec_response = MessageSpecification(
                srv_spec.pkg_name, 'WriteSample%sResponse' % srv_spec.srv_name, response_fields,
                constants)

            generated_files = [
                (sample_spec_request,
                 os.path.join(output_dir, '%s_.idl' % sample_spec_request.base_type.type)),
                (sample_spec_response,
                 os.path.join(output_dir, '%s_.idl' % sample_spec_response.base_type.type)),
                (write_sample_spec_request,
                 os.path.join(output_dir, '%s_.idl' % write_sample_spec_request.base_type.type)),
                (write_sample_spec_response,
                 os.path.join(output_dir, '%s_.idl' % write_sample_spec_response.base_type.type)),
            ]

            for spec, generated_file in generated_files:
                print('Generating SERVICE supporting file: %s' % generated_file)

                try:
                    # TODO only touch generated file if its content actually changes
                    ofile = open(generated_file, 'w')
                    data = {'spec': spec, 'subfolders': subfolders}
                    data.update(functions)
                    # TODO reuse interpreter
                    interpreter = em.Interpreter(
                        output=ofile,
                        options={
                            em.RAW_OPT: True,
                            em.BUFFERED_OPT: True,
                        },
                        globals=data,
                    )
                    interpreter.file(open(template_file_srv))
                    interpreter.shutdown()
                except Exception:
                    os.remove(generated_file)
                    raise

    return 0


# used by the template
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
    include_directives = set([])
    for field in spec.fields:
        if field.type.is_primitive_type():
            continue
        include_directive = '#include "%s/%s_.idl"' % \
            ('/'.join([field.type.pkg_name] + subfolders), field.type.type)
        include_directives.add(include_directive)
    return sorted(include_directives)


# used by the template
def msg_type_to_idl(type_):
    """
    Convert a message type into the DDS declaration.

    Example input: uint32, std_msgs/String
    Example output: uint32_t, std_msgs::String_<ContainerAllocator>

    @param type: The message type
    @type type: rosidl_parser.Type
    """
    if type_.is_primitive_type():
        idl_type = MSG_TYPE_TO_IDL[type_.type]
    else:
        idl_type = '%s::dds_::%s_' % (type_.pkg_name, type_.type)
    return _msg_type_to_idl(type_, idl_type)


def _msg_type_to_idl(type_, idl_type):
    if type_.is_array:
        if type_.array_size is None or type_.is_upper_bound:
            sequence_type = idl_type
            if type_.is_upper_bound:
                sequence_type += ', %u' % type_.array_size
            return ['', '', 'sequence<%s>' % sequence_type]
        else:
            typename = '%s_array_%s' % \
                (idl_type.replace(' ', '_'), type_.array_size)
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
