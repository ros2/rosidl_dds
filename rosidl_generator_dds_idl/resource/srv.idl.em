@# Included from rosidl_generator_dds_idl/resource/idl.idl.em
@(
    TEMPLATE(
        'msg.idl.em', package_name=package_name,
        interface_path=interface_path,
        message=service.request_message
    )
)@
@(
    TEMPLATE(
        'msg.idl.em', package_name=package_name,
        interface_path=interface_path,
        message=service.response_message
    )
)@
