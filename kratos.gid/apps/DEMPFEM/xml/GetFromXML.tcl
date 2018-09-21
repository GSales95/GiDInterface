namespace eval DEMPFEM::xml {
    # Namespace variables declaration
    variable dir
}

proc DEMPFEM::xml::Init { } {
    # Namespace variables initialization
    variable dir
    Model::InitVariables dir $DEMPFEM::dir

    Model::ForgetElement SphericPartDEMElement3D
    Model::getElements Elements.xml
}

proc DEMPFEM::xml::getUniqueName {name} {
    return ${::DEMPFEM::prefix}${name}
}

proc DEMPFEM::xml::CustomTree { args } {
    DEM::xml::CustomTree
    PfemFluid::xml::CustomTree
    spdAux::SetValueOnTreeItem values Fluid PFEMFLUID_DomainType
}

DEMPFEM::xml::Init
