
proc Fluid::xml::ImportMeshWindow { } {
    set filenames [Browser-ramR file read .gid [_ "Read mesh file"] \
		{} [list [list {STL Mesh} {.stl }] [list [_ "All files"] {.*}]] {} 1 \
        [list [_ "Import options"] Fluid::xml::MoreImportOptions]]
    if {[llength $filenames] == 0} { return "" }
    set filename [lindex $filenames 0]
    set model_name [file rootname [file tail $filename]]
    if {[GiD_Layers exists $model_name]} {
        set i 0
        set orig $model_name
        while {[GiD_Layers exists $model_name]} {
            set model_name ${orig}$i
            incr i
        }
    }
    GidUtils::DisableGraphics
    GiD_Layers create $model_name
    GiD_Layers edit to_use $model_name
    
    if {[lindex [GiD_Info Mesh] 0]} {
        GiD_Process Mescape Files STLRead Append $filename
    } else {
        GiD_Process Mescape Files STLRead $filename
    }
    

    if {![GiD_Groups exists $model_name]} {GiD_Groups create $model_name}
    
    GiD_Process Mescape Geometry Edit ReConstruction OneSurfForEachElement Layer:$model_name escape 
    GiD_EntitiesGroups assign $model_name surfaces [GiD_EntitiesLayers get $model_name surfaces]
    GiD_EntitiesGroups assign $model_name lines [GiD_EntitiesLayers get $model_name lines]
    GiD_EntitiesGroups assign $model_name points [GiD_EntitiesLayers get $model_name points]
    
    GiD_Process Mescape Meshing AssignSizes Surfaces $Fluid::xml::lastImportMeshSize selection {*}[GiD_EntitiesLayers get $model_name surfaces] MEscape 

    
    GidUtils::EnableGraphics
    GidUtils::UpdateWindow GROUPS
    GidUtils::UpdateWindow LAYER
    
    GiD_Process 'Zoom Frame
    
    GidUtils::SetWarnLine [= "STL %s imported!" $model_name]
    
    apps::ExecuteOnCurrentXML WindTunnelImportPart [dict create group $model_name size $Fluid::xml::lastImportMeshSize]
    
    spdAux::RequestRefresh
}

proc Fluid::xml::MoreImportOptions { f } {
    if {$Fluid::xml::lastImportMeshSize == 0} {set Fluid::xml::lastImportMeshSize 1000}
    ttk::label $f.lblGeometry -text [= "Mesh size"]:
    ttk::entry $f.entGeometry -textvariable Fluid::xml::lastImportMeshSize
    grid columnconfigure $f 1 -weight 1
    grid $f.lblGeometry $f.entGeometry -sticky w 

    variable export_dir
    if { ![info exists export_dir] } {
        #trick to show the more options
        set export_dir open
    }
    return Fluid::xml::export_dir
}

Fluid::xml::Init
