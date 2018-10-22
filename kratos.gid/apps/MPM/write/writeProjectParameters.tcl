# Project Parameters
proc ::MPM::write::getParametersDict { } {
    set project_parameters_dict [Structural::write::getParametersEvent]

    # Quasi-static must be written as Quasi-static...
    set solutiontype [write::getValue STSoluType]
    dict set project_parameters_dict solver_settings solver_type $solutiontype

    # Change the model part name
    dict set project_parameters_dict solver_settings model_part_name MPM_Material
        
    # create grid_import_settings
    set grid_import_settings_dict [dict get $project_parameters_dict solver_settings model_import_settings]
    dict append grid_import_settings_dict input_filename _Grid
    dict set project_parameters_dict solver_settings grid_model_import_settings $grid_import_settings_dict
    
    # add _Body to model_import_settings
    set model_import_settings_dict [dict get $project_parameters_dict solver_settings model_import_settings]
    dict append model_import_settings_dict input_filename _Body
    dict set project_parameters_dict solver_settings model_import_settings $model_import_settings_dict

    # materials file
    dict set project_parameters_dict solver_settings material_import_settings materials_filename [GetAttribute materials_file]
    
    # Geometry in elements
    set geometry_element [dict get $project_parameters_dict solver_settings geometry_element]
    if {$geometry_element eq "Triangle"} {
        dict unset project_parameters_dict solver_settings particle_per_element_quadrilateral
        set number [dict get $project_parameters_dict solver_settings particle_per_element_triangle]
        dict unset project_parameters_dict solver_settings particle_per_element_triangle
    } else {
        dict unset project_parameters_dict solver_settings particle_per_element_triangle
        set number [dict get $project_parameters_dict solver_settings particle_per_element_quadrilateral]
        dict unset project_parameters_dict solver_settings particle_per_element_quadrilateral
    }
    dict set project_parameters_dict solver_settings particle_per_element $number

    # Pressure dofs
    dict set project_parameters_dict solver_settings pressure_dofs false

    # Add the solver information
    set solverSettingsDict [dict get $project_parameters_dict solver_settings]
    set solverSettingsDict [dict merge $solverSettingsDict [write::getSolversParametersDict MPM] ]
    dict set project_parameters_dict solver_settings $solverSettingsDict

    # Move slip to constraints
    set slip_process_list [list ]
    set new_load_process_list [list ]
    set load_process_list [dict get $project_parameters_dict processes loads_process_list]
    foreach load $load_process_list {
        if {[dict get $load python_module] eq "apply_mpm_slip_boundary_process"} {
            lappend slip_process_list $load
        } else {
            lappend new_load_process_list $load
        }
    }
    dict set project_parameters_dict processes loads_process_list $new_load_process_list
    dict set project_parameters_dict processes list_other_processes $slip_process_list

    # Gravity
    set gravity_dict [dict create ]
    dict set gravity_dict python_module assign_gravity_to_particle_process
    dict set gravity_dict kratos_module "KratosMultiphysics.ParticleMechanicsApplication"
    dict set gravity_dict process_name AssignGravityToParticleProcess
    set gravity_parameters_dict [dict create ]
    dict set gravity_parameters_dict model_part_name MPM_Material
    dict set gravity_parameters_dict variable_name MP_VOLUME_ACCELERATION
    dict set gravity_parameters_dict modulus [write::getValue MPMGravity modulus]
    lassign [write::getValue MPMGravity direction] dx dy dz
    dict set gravity_parameters_dict direction [list [expr $dx] [expr $dy] [expr $dz]]
    dict set gravity_dict Parameters $gravity_parameters_dict
    dict set project_parameters_dict processes gravity [list $gravity_dict]

    # Output configuration
    set body_output_configuration_dict [lindex [dict get $project_parameters_dict output_processes gid_output] 0]
    set grid_output_configuration_dict [lindex [dict get $project_parameters_dict output_processes gid_output] 0]
    dict set body_output_configuration_dict Parameters model_part_name MPM_Material
    dict set grid_output_configuration_dict Parameters model_part_name MPM_Material
    dict unset body_output_configuration_dict Parameters postprocess_parameters result_file_configuration nodal_results
    dict unset grid_output_configuration_dict Parameters postprocess_parameters result_file_configuration gauss_point_results
    dict set project_parameters_dict output_processes body_output_process [list $body_output_configuration_dict]
    dict set project_parameters_dict output_processes grid_output_process [list $grid_output_configuration_dict]
    dict unset project_parameters_dict output_processes gid_output

    return $project_parameters_dict
}
proc ::MPM::write::writeParametersEvent { } {
    write::WriteJSON [getParametersDict]
}

