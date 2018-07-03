namespace eval FreeSurfaceFlow::xml {
    # Namespace variables declaration
    variable dir
    variable export_dir
}

proc FreeSurfaceFlow::xml::Init { } {
    # Namespace variables inicialization
    variable dir
    Model::InitVariables dir $FreeSurfaceFlow::dir

    Model::ForgetSolutionStrategies
    Model::getSolutionStrategies Strategies.xml
}

proc FreeSurfaceFlow::xml::MultiAppEvent {args} {
    if {$args eq "init"} {
        spdAux::parseRoutes
        spdAux::ConvertAllUniqueNames FL ${::FreeSurfaceFlow::prefix}
    }
}

proc FreeSurfaceFlow::xml::getUniqueName {name} {
    return ${::FreeSurfaceFlow::prefix}${name}
}

proc FreeSurfaceFlow::xml::CustomTree { args } {    

}

FreeSurfaceFlow::xml::Init
