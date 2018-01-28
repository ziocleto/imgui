project "imgui"
    kind "StaticLib"
    files { "../*.h", "../*.cpp" }
    vpaths { ["imgui"] = { "../*.cpp", "../*.h", "libs/*.natvis" } }
    filter { "toolset:msc*" }
        files { "libs/*.natvis" }
         