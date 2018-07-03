namespace eval FreeSurfaceFlow::write {
    # Namespace variables declaration
    variable writeAttributes
}

proc FreeSurfaceFlow::write::Init { } {
    # Namespace variables inicialization
    variable FluidConditions
    set FluidConditions(temp) 0
    unset FluidConditions(temp)

    SetAttribute parts_un FLParts
    SetAttribute nodal_conditions_un FLNodalConditions
    SetAttribute conditions_un FLBC
    SetAttribute materials_un FLMaterials
    SetAttribute drag_un FLDrags
    SetAttribute writeCoordinatesByGroups 0
    SetAttribute validApps [list "Fluid" "FreeSurfaceFlow"]
    SetAttribute main_script_file "KratosFluid.py"
    SetAttribute materials_file "FluidMaterials.json"
    SetAttribute properties_location "mdpa"
}

proc FreeSurfaceFlow::write::GetAttribute {att} {
    variable writeAttributes
    return [dict get $writeAttributes $att]
}

proc FreeSurfaceFlow::write::GetAttributes {} {
    variable writeAttributes
    return $writeAttributes
}

proc FreeSurfaceFlow::write::SetAttribute {att val} {
    variable writeAttributes
    dict set writeAttributes $att $val
}

proc FreeSurfaceFlow::write::AddAttribute {att val} {
    variable writeAttributes
    dict lappend writeAttributes $att $val
}

proc FreeSurfaceFlow::write::AddAttributes {configuration} {
    variable writeAttributes
    set writeAttributes [dict merge $writeAttributes $configuration]
}

proc FreeSurfaceFlow::write::AddValidApps {appid} {
    AddAttribute validApps $appid
}

proc FreeSurfaceFlow::write::SetCoordinatesByGroups {value} {
    SetAttribute writeCoordinatesByGroups $value
}

# Events
proc FreeSurfaceFlow::write::writeModelPartEvent { } {
    # Validation
    set err [Validate]
    if {$err ne ""} {error $err}

}
proc FreeSurfaceFlow::write::writeCustomFilesEvent { } {
    # Materials file TODO -> Python script must read from here
    #write::writePropertiesJsonFile [GetAttribute parts_un] [GetAttribute materials_file]

    # Main python script
    set orig_name [GetAttribute main_script_file]
    write::CopyFileIntoModel [file join "python" $orig_name ]
    write::RenameFileInModel $orig_name "MainKratos.py"
}

proc FreeSurfaceFlow::write::Validate {} {
    set err ""    
    set root [customlib::GetBaseRoot]

    return $err
}

FreeSurfaceFlow::write::Init
