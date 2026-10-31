# Defines ziti-deps::ziti, the static libziti and everything it links, for the prefix this file ships in.
get_filename_component(_zd_prefix "${CMAKE_CURRENT_LIST_DIR}/../../.." ABSOLUTE)

if (NOT TARGET ziti-deps::ziti)
    add_library(ziti-deps::ziti INTERFACE IMPORTED)
    set(_zd_libs ziti tlsuv stc uv ssl crypto sodium json-c protobuf-c llhttp z)
    set(_zd_files "")
    foreach (_zd_lib IN LISTS _zd_libs)
        list(APPEND _zd_files "${_zd_prefix}/lib/lib${_zd_lib}.a")
    endforeach ()
    set_target_properties(ziti-deps::ziti PROPERTIES
            INTERFACE_INCLUDE_DIRECTORIES "${_zd_prefix}/include"
            INTERFACE_LINK_LIBRARIES "${_zd_files};pthread;dl;m")
endif ()
