# Project Parameters
proc ::FreeSurfaceFlow::write::getParametersDict { } {
    set projectParametersDict [dict create]

    
    return $projectParametersDict
}

proc FreeSurfaceFlow::write::writeParametersEvent { } {
    set projectParametersDict [getParametersDict]
    write::SetParallelismConfiguration
    write::WriteJSON $projectParametersDict
}
