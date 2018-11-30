@# Included from rosidl_generator_dds_idl/resource/idl.idl.em
@{
TEMPLATE(
    'srv.idl.em',
    package_name=package_name,
    interface_path=interface_path,
    message=action.goal_service
)

TEMPLATE(
    'srv.idl.em',
    package_name=package_name,
    interface_path=interface_path,
    message=action.result_service
)

TEMPLATE(
    'msg.idl.em',
    package_name=package_name,
    interface_path=interface_path,
    message=action.feedback_message
)
}@
