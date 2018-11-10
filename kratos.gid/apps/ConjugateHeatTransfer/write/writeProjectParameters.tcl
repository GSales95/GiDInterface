# Project Parameters
proc ::ConjugateHeatTransfer::write::getParametersDict { } {
    
    set projectParametersDict [dict create]

    # Set the problem data section
    dict set projectParametersDict problem_data [write::GetDefaultProblemDataDict]

    return $projectParametersDict
    # Solver settings
    dict set projectParametersDict solver_settings [ConjugateHeatTransfer::write::GetSolverSettingsDict]

    set processes [dict create]
    # Boundary conditions processes
    dict set processes initial_conditions_process_list [write::getConditionsParametersDict [GetAttribute nodal_conditions_un] "Nodal"]
    dict set processes constraints_process_list [write::getConditionsParametersDict [GetAttribute conditions_un]]
    # dict set processes fluxes_process_list [write::getConditionsParametersDict [GetAttribute conditions_un]]
    dict set processes list_other_processes [list [getBodyForceProcessDict] ]
    
    dict set projectParametersDict processes $processes
    # Output configuration
    dict set projectParametersDict output_processes [GetOutputProcessList]

    # Restart options
    dict set projectParametersDict restart_options [write::GetDefaultRestartDict]


    return $projectParametersDict
}

proc ConjugateHeatTransfer::write::writeParametersEvent { } {
    set projectParametersDict [getParametersDict]
    write::SetParallelismConfiguration
    write::WriteJSON $projectParametersDict
}

# Body force SubModelParts and Process collection
proc ConjugateHeatTransfer::write::getBodyForceProcessDict {} {
    set root [customlib::GetBaseRoot]

    set value [write::getValue CNVDFFBodyForce BodyForceValue]
    set pdict [dict create]
    dict set pdict "python_module" "assign_scalar_variable_process"
    dict set pdict "kratos_module" "KratosMultiphysics"
    dict set pdict "process_name" "AssignScalarVariableProcess"
    set params [dict create]
    set partgroup [write::getPartsSubModelPartId]
    dict set params "model_part_name" [concat [lindex $partgroup 0]]
    dict set params "variable_name" "HEAT_FLUX"
    dict set params "value" $value
    dict set params "constrained" false
    dict set pdict "Parameters" $params

    return $pdict
}

proc ConjugateHeatTransfer::write::GetSolverSettingsDict {} {
    set solverSettingsDict [dict create]
    set currentStrategyId [write::getValue CNVDFFSolStrat]
    set currentAnalysisTypeId [write::getValue CNVDFFAnalysisType]
    dict set solverSettingsDict solver_type $currentStrategyId
    dict set solverSettingsDict analysis_type $currentAnalysisTypeId
    dict set solverSettingsDict model_part_name [GetAttribute model_part_name]
    set nDim [expr [string range [write::getValue nDim] 0 0]]
    dict set solverSettingsDict domain_size $nDim

    # Model import settings
    set modelDict [dict create]
    dict set modelDict input_type "mdpa"
    set model_name [file tail [GiD_Info Project ModelName]]
    dict set modelDict input_filename $model_name
    dict set solverSettingsDict model_import_settings $modelDict

    set materialsDict [dict create]
    dict set materialsDict materials_filename [GetAttribute materials_file]
    dict set solverSettingsDict material_import_settings $materialsDict

    set solverSettingsDict [dict merge $solverSettingsDict [write::getSolutionStrategyParametersDict CNVDFFSolStrat CNVDFFScheme CNVDFFStratParams] ]
    set solverSettingsDict [dict merge $solverSettingsDict [write::getSolversParametersDict ConjugateHeatTransfer] ]

    # Parts
    dict set solverSettingsDict problem_domain_sub_model_part_list [write::getSubModelPartNames [GetAttribute parts_un]]
    dict set solverSettingsDict processes_sub_model_part_list [write::getSubModelPartNames [GetAttribute nodal_conditions_un] [GetAttribute conditions_un] ]

    # Time stepping settings
    set timeSteppingDict [dict create]
    if {[write::getValue CNVDFFSolStrat] eq "transient"} {
        dict set timeSteppingDict "time_step" [write::getValue CNVDFFTimeParameters DeltaTime]
    } else {
        dict set timeSteppingDict time_step 1.0
    }
    dict set solverSettingsDict time_stepping $timeSteppingDict

    return $solverSettingsDict
}

proc ConjugateHeatTransfer::write::GetOutputProcessList { } {
    set result [dict create ]
    
    set gid_output [list ]
    set res_dict [dict create]
    dict set res_dict python_module gid_output_process
    dict set res_dict kratos_module KratosMultiphysics
    dict set res_dict process_name GiDOutputProcess
    dict set res_dict Parameters postprocess_parameters [write::GetDefaultOutputDict]
    
    set partgroup [write::getPartsSubModelPartId]
    dict set res_dict Parameters "model_part_name" [concat [lindex $partgroup 0]]
    set model_name [file tail [GiD_Info Project ModelName]]
    dict set res_dict Parameters output_name $model_name
    lappend gid_output $res_dict
    dict set result gid_output $gid_output
    return $result
}