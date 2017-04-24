
namespace eval WindTunnelWizard::Wizard {
    # Namespace variables declaration
    variable entrywidth
    set entrywidth 16
    variable borderwidth
    set borderwidth 10
}

proc WindTunnelWizard::Wizard::Init { } {
#W "Carga los pasos"
}

proc WindTunnelWizard::Wizard::Fluid { win } {
    variable entrywidth
    variable borderwidth
    # Left frame
    set fr1 [ttk::frame $win.fr1 -borderwidth $borderwidth]

    # Rigth frame
    set fr2 [ttk::frame $win.fr2 -borderwidth $borderwidth]

    set img1  [apps::getImgFrom Fluid "tunnel.png"]
    set labIm [ttk::label $fr2.lIm -image $img1]
    
    # Fluid frame
    set labfr1 [ttk::labelframe $fr1.lfr1 -text [= "Fluid properties"] -padding 10 ]
    set props [GetFluidProperties]

    set i 0
    set props 
    foreach prop $props {
        set pn $::Wizard::wprops(Material,$prop,name)
        set unit $::Wizard::wprops(Material,$prop,unit)
        set lab$i [ttk::label $labfr1.l$i -text "${pn}:"]
        set ent$i [ttk::entry $labfr1.e$i -textvariable ::Wizard::wprops(Material,$prop,value) -width $entrywidth]
        set labun$i [ttk::label $labfr1.u$i -text "${unit}"]
        wcb::callback $labfr1.e$i before insert wcb::checkEntryForReal
        set txt [= "Enter a value for $pn"]
        tooltip::tooltip $labfr1.e$i "${txt}."
        incr i
    }
    

    grid $fr1 -column 1 -row 0 -sticky nw
    grid $fr2 -column 2 -row 0 -sticky ne

    
     grid $labIm -column 0 -row 0 -sticky ne -rowspan 3
    
     # Label frames
     grid $labfr1 -column 1 -row 0 -sticky wen -ipadx 2  -columnspan 2

     for {set j 0} {$j < $i} {incr j} {
        set lab "lab$j"
        set ent "ent$j"
        set labun "labun$j"
        
        grid [expr $$lab] -column 1 -row $j -sticky w -pady 2
        grid [expr $$ent] -column 2 -row $j -sticky w -pady 2
        grid [expr $$labun] -column 3 -row $j -sticky w
          
     }
    
}
proc WindTunnelWizard::Wizard::NextFluid { } {
    if {![GiD_Groups exists "FluidBox"]} {W "Fluid group must be named as 'FluidBox'"; return ""}
    gid_groups_conds::delete "[spdAux::getRoute FLParts]/group"
    set gnode [spdAux::AddConditionGroupOnXPath [spdAux::getRoute FLParts] "FluidBox"]
    [$gnode selectNodes "./value\[@n = 'DENSITY'\]"] setAttribute v $::Wizard::wprops(Material,DENSITY,value)
    [$gnode selectNodes "./value\[@n = 'VISCOSITY'\]"] setAttribute v $::Wizard::wprops(Material,VISCOSITY,value)

}
proc WindTunnelWizard::Wizard::GetFluidProperties { } {
    set props [list DENSITY VISCOSITY]
    foreach prop $props {
        set node [[customlib::GetBaseRoot] selectNodes "[spdAux::getRoute FLParts]/group"]
        if {$node eq ""} {set node [[customlib::GetBaseRoot] selectNodes [spdAux::getRoute FLParts]]}
        set node [$node selectNodes "./value\[@n='$prop'\]"]
        set ::Wizard::wprops(Material,$prop,name)  [get_domnode_attribute $node pn]
        set ::Wizard::wprops(Material,$prop,value) [get_domnode_attribute $node v]
        set ::Wizard::wprops(Material,$prop,unit)  [get_domnode_attribute $node units]
    }
    
    return $props
}

proc WindTunnelWizard::Wizard::Conditions { win } {
     
}
proc WindTunnelWizard::Wizard::NextConditions { } {

}
proc WindTunnelWizard::Wizard::Simulation { win } {
     
}
proc WindTunnelWizard::Wizard::NextSimulation { } {

}


WindTunnelWizard::Wizard::Init

