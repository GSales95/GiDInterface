# Project Parameters
proc ::ConjugateHeatTransfer::write::getParametersDict { } {
    InitExternalProjectParameters
    
    set projectParametersDict [dict create]

    # Set the problem data section
    dict set projectParametersDict problem_data [write::GetDefaultProblemDataDict]

    # Solver settings
    dict set projectParametersDict solver_settings [ConjugateHeatTransfer::write::GetSolverSettingsDict]

    # output processes
    dict set projectParametersDict output_processes [ConjugateHeatTransfer::write::GetOutputProcessList]

    # Restart options
    dict set projectParametersDict restart_options [write::GetDefaultRestartDict]

    # processes
    dict set projectParametersDict processes [ConjugateHeatTransfer::write::GetProcessList]

    return $projectParametersDict
    
}

proc ConjugateHeatTransfer::write::writeParametersEvent { } {
    set projectParametersDict [getParametersDict]
    write::SetParallelismConfiguration
    write::WriteJSON $projectParametersDict
}

proc ConjugateHeatTransfer::write::GetSolverSettingsDict {} {
    set solver_settings_dict [dict create]
    dict set solver_settings_dict solver_type "conjugate_heat_transfer"
    set nDim [expr [string range [write::getValue nDim] 0 0]]
    dict set solver_settings_dict domain_size $nDim
    
    set filename [Kratos::GetModelName]

    # Prepare the solver strategies
    # Buoyancy Fluid > Modelpart name -> mdpa fluid   
    dict set ConjugateHeatTransfer::write::fluid_domain_solver_settings solver_settings fluid_solver_settings model_import_settings input_filename "${filename}_[GetAttribute fluid_mdpa_suffix]"
    # Buoyancy Thermic > Modelpart name -> none
    dict set ConjugateHeatTransfer::write::fluid_domain_solver_settings solver_settings thermal_solver_settings model_import_settings input_filename "use_input_model_part"
    dict unset ConjugateHeatTransfer::write::fluid_domain_solver_settings solver_settings thermal_solver_settings model_import_settings input_type
    # Solid Thermic > Modelpart name -> mdpa solid
    dict set ConjugateHeatTransfer::write::solid_domain_solver_settings solver_settings model_import_settings input_filename "${filename}_[GetAttribute solid_mdpa_suffix]"

    dict set solver_settings_dict fluid_domain_solver_settings [dict get $ConjugateHeatTransfer::write::fluid_domain_solver_settings solver_settings]
    dict set solver_settings_dict solid_domain_solver_settings thermal_solver_settings [dict get $ConjugateHeatTransfer::write::solid_domain_solver_settings solver_settings]

    # Coupling settings
    set fluid_interfaces_list [write::GetSubModelPartFromCondition FLBC FluidNoSlipInterface$::Model::SpatialDimension]
    set solid_interfaces_list [write::GetSubModelPartFromCondition CNVDFFBC ConvectionDiffusionInterface$::Model::SpatialDimension]

    set coupling_settings [dict create]
    dict set coupling_settings max_iteration 10
    dict set coupling_settings relaxation_factor 0.7
    dict set coupling_settings temperature_relative_tolerance 1e-5
    dict set coupling_settings fluid_interfaces_list $fluid_interfaces_list
    dict set coupling_settings solid_interfaces_list $solid_interfaces_list
    dict set solver_settings_dict coupling_settings $coupling_settings

    return $solver_settings_dict
}

proc ConjugateHeatTransfer::write::GetProcessList { } {
    # TODO: Hacerlo bien, cada cosa en su sublista
    set processes [dict create ]
    
    return $processes
}
proc ConjugateHeatTransfer::write::GetOutputProcessList { } {
    set output_process [dict create ]
    
    lappend fluid_output [lindex [dict get $ConjugateHeatTransfer::write::fluid_domain_solver_settings output_processes gid_output] 0]
    dict set output_process fluid_output_processes $fluid_output

    lappend solid_output [lindex [dict get $ConjugateHeatTransfer::write::solid_domain_solver_settings output_processes gid_output] 0]
    dict set output_process solid_output_processes $solid_output
    
    return $output_process
}

proc ConjugateHeatTransfer::write::InitExternalProjectParameters { } {
    # Buoyancy section
    apps::setActiveAppSoft Buoyancy
    write::initWriteConfiguration [Buoyancy::write::GetAttributes]
    set ConjugateHeatTransfer::write::fluid_domain_solver_settings [Buoyancy::write::getParametersDict]

    # Heating section
    apps::setActiveAppSoft ConvectionDiffusion
    write::initWriteConfiguration [ConvectionDiffusion::write::GetAttributes]
    set ConjugateHeatTransfer::write::solid_domain_solver_settings [ConvectionDiffusion::write::getParametersDict]

    apps::setActiveAppSoft ConjugateHeatTransfer
}