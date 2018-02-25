
-- We use Premake5 to generate project files (Visual Studio solutions, XCode solutions, Makefiles, etc.)
-- Download Premake5: at https://premake.github.io/download.html
-- YOU NEED PREMAKE 5.0 ALPHA 10 (Oct 2016) or later

--------- HELP
-- To reduce friction for people who don't aren't used to Premake, we list some concrete usage examples.

if _ACTION == nil then
	print "-----------------------------------------"
	print " DEAR IMGUI EXAMPLES - PROJECT GENERATOR"
	print "-----------------------------------------"
	print "Usage:"
	print "  premake5 [generator] [options]"
	print "Example:"
	print "  premake5 vs2010"
	print "  premake5 vs2015 --with-sdl --with-vulkan"
	print "  premake5 xcode4 --with-glfw"
	print "  premake5 gmake2 --with-glfw"
	print "Generators:"
	print "  codelite gmake gmake2 vs2008 vs2010 vs2012 vs2013 vs2015 vs2017 xcode4 etc."
	print "Options:"
	print "  --with-dx9       Enable dear imgui DirectX 9 example"
	print "  --with-dx10      Enable dear imgui DirectX 10 example"
	print "  --with-dx11      Enable dear imgui DirectX 11 example"
	print "  --with-dx12      Enable dear imgui DirectX 12 example (vs2015+)"
	print "  --with-glfw      Enable dear imgui GLFW examples"
	print "  --with-sdl       Enable dear imgui SDL examples"
	print "  --with-vulkan    Enable dear imgui Vulkan example"
	print "Project and object files will be created in the build/ folder. You can delete your build/ folder at any time."
	print ""
end

---------- OPTIONS

newoption { trigger = "with-dx9",    description="Enable dear imgui DirectX 9 example" }
newoption { trigger = "with-dx10",   description="Enable dear imgui DirectX 10 example" }
newoption { trigger = "with-dx11",   description="Enable dear imgui DirectX 11 example" }
newoption { trigger = "with-dx12",   description="Enable dear imgui DirectX 12 example" }
newoption { trigger = "with-glfw",   description="Enable dear imgui GLFW examples" }
newoption { trigger = "with-sdl",    description="Enable dear imgui SDL examples" }
newoption { trigger = "with-vulkan", description="Enable dear imgui Vulkan example" }

-- Enable/detect default options under Windows
if _ACTION ~= nil and ((os.istarget ~= nil and os.istarget("windows")) or (os.is ~= nil and os.is("windows"))) then
	print("( enabling --with-dx9 )");
	print("( enabling --with-dx10 )");
	print("( enabling --with-dx11 )");
	_OPTIONS["with-dx9"] = 1
	_OPTIONS["with-dx10"] = 1
	_OPTIONS["with-dx11"] = 1
	if _ACTION >= "vs2015" then
		print("( enabling --with-dx12 because compiler is " .. _ACTION .. " )");
		_OPTIONS["with-dx12"] = 1
	end
	print("( enabling --with-glfw because GLFW is included in the libs/ folder )");
	_OPTIONS["with-glfw"] = 1
	if os.getenv("SDL2_DIR") then
		print("( enabling --with-sdl because SDL2_DIR environment variable was found )");
		_OPTIONS["with-sdl"] = 1
	end
	if os.getenv("VULKAN_SDK") then
		print("( enabling --with-vulkan because VULKAN_SDK environment variable was found )");
		_OPTIONS["with-vulkan"] = 1
	end
end


--------- HELPER FUNCTIONS

-- Helper function: add dear imgui source files into project
function imgui_as_src(fs_path, project_path)
	if (project_path == nil) then project_path = fs_path; end;	        -- default to same virtual folder as the file system folder (in this project it would be ".." !)

	files { fs_path .. "/*.cpp", fs_path .. "/*.h" }
	includedirs { fs_path }
	vpaths { [project_path] = { fs_path .. "/*.*", "libs/*.natvis" } }  -- add in a specific folder of the Visual Studio project
	filter { "toolset:msc*" }
		files { "libs/*.natvis" }
	filter {}
end

-- Helper function: add dear imgui as a library (uncomment the 'include "premake5-lib"' line)
--include "premake5-lib"
function imgui_as_lib(fs_path)
	includedirs { fs_path }
	links "imgui"
end

--------- SOLUTION, PROJECTS

workspace "imgui_examples"
	configurations { "Debug", "Release" }
	platforms { "x86", "x86_64" }

	location "build/"
	symbols "On"
	warnings "Extra"
	--flags { "FatalCompileWarnings"}

	filter { "configurations:Debug" }
		optimize "Off"
	filter { "configurations:Release" }
		optimize "On"

-- directx11_example (Win32 + DirectX 11)
-- We have DX11 as the first project because this is what Visual Studio uses
if (_OPTIONS["with-dx11"]) then
	project "directx11_example"
		kind "ConsoleApp"
		imgui_as_src ("..", "imgui")
		--imgui_as_lib ("..")
		files { "directx11_example/*.cpp", "directx11_example/*.h", "README.txt" }
		vpaths { ["sources"] = "*_example/**" }
		filter { "system:windows", "toolset:msc-v80 or msc-v90 or msc-v100" }
			includedirs { "$(DXSDK_DIR)/Include" }
		filter { "system:windows", "toolset:msc-v80 or msc-v90 or msc-v100", "platforms:x86" }
			libdirs { "$(DXSDK_DIR)/Lib/x86" }
		filter { "system:windows", "toolset:msc-v80 or msc-v90 or msc-v100", "platforms:x86_64" }
			libdirs { "$(DXSDK_DIR)/Lib/x64" }
		filter { "system:windows" }
			links { "d3d11", "d3dcompiler", "dxgi" }
end

-- directx9_example (Win32 + DirectX 9)
if (_OPTIONS["with-dx9"]) then
	project "directx9_example"
		kind "ConsoleApp"
		imgui_as_src ("..", "imgui")
		--imgui_as_lib ("..")
		files { "directx9_example/*.cpp", "directx9_example/*.h", "README.txt" }
		vpaths { ["sources"] = "*_example/**" }
		filter { "system:windows" }
			links { "d3d9" }
end

-- directx10_example (Win32 + DirectX 10)
if (_OPTIONS["with-dx10"]) then
	project "directx10_example"
		kind "ConsoleApp"
		imgui_as_src ("..", "imgui")
		--imgui_as_lib ("..")
		files { "directx10_example/*.cpp", "directx10_example/*.h", "README.txt" }
		vpaths { ["sources"] = "*_example/**" }
		filter { "system:windows", "toolset:msc-v80 or msc-v90 or msc-v100" }
			includedirs { "$(DXSDK_DIR)/Include" }
		filter { "system:windows", "toolset:msc-v80 or msc-v90 or msc-v100", "platforms:x86" }
			libdirs { "$(DXSDK_DIR)/Lib/x86" }
		filter { "system:windows", "toolset:msc-v80 or msc-v90 or msc-v100", "platforms:x86_64" }
			libdirs { "$(DXSDK_DIR)/Lib/x64" }
		filter { "system:windows" }
			links { "d3d10", "d3dcompiler", "dxgi" }
end

-- directx12_example (Win32 + DirectX 12)
if (_OPTIONS["with-dx12"]) then
	project "directx12_example"
		kind "ConsoleApp"
		systemversion "10.0.16299.0"
		imgui_as_src ("..", "imgui")
		--imgui_as_lib ("..")
		files { "directx12_example/*.cpp", "directx12_example/*.h", "README.txt" }
		vpaths { ["sources"] = "*_example/**" }
		filter { "system:windows" }
			links { "d3d12", "d3dcompiler", "dxgi" }
end

-- opengl2_example (GLFW + OpenGL2)
if (_OPTIONS["with-glfw"]) then
	project "opengl2_example"
		kind "ConsoleApp"
		imgui_as_src ("..", "imgui")
		--imgui_as_lib ("..")
		files { "opengl2_example/*.h", "opengl2_example/*.cpp", "README.txt"}
		vpaths { ["sources"] = "*_example/**" }
		includedirs { "libs/glfw/include" }
		filter { "system:windows", "platforms:x86" }
			libdirs { "libs/glfw/lib-vc2010-32" }
		filter { "system:windows", "platforms:x86_64" }
			libdirs { "libs/glfw/lib-vc2010-64" }
		filter { "system:windows" }
			ignoredefaultlibraries { "msvcrt" }
			links { "opengl32", "glfw3" }
		filter { "system:macosx" }
			libdirs { "/usr/local/lib" }
			links { "glfw" }
			linkoptions { "-framework OpenGL" }
end

-- opengl3_example (GLFW + OpenGL3)
if (_OPTIONS["with-glfw"]) then
	project "opengl3_example"
		kind "ConsoleApp"
		imgui_as_src ("..", "imgui")
		--imgui_as_lib ("..")
		vpaths { ["sources"] = "*_example/**", ["libs/gl3w/GL"] = "libs/gl3w/GL/**" }
		files { "opengl3_example/*.h", "opengl3_example/*.cpp", "./README.txt", "libs/gl3w/GL/gl3w.c" }
		includedirs { "libs/glfw/include", "libs/gl3w" }
		filter { "system:windows", "platforms:x86" }
			libdirs { "libs/glfw/lib-vc2010-32" }
		filter { "system:windows", "platforms:x86_64" }
			libdirs { "libs/glfw/lib-vc2010-64" }
		filter { "system:windows" }
			ignoredefaultlibraries { "msvcrt" }
			links { "opengl32", "glfw3" }
		filter { "system:macosx" }
			libdirs { "/usr/local/lib" }
			links { "glfw" }
			linkoptions { "-framework OpenGL" }
end

-- null_example (no rendering)
if (true) then
	project "null_example"
		kind "ConsoleApp"
		imgui_as_src ("..", "imgui")
		--imgui_as_lib ("..")
		vpaths { ["sources"] = "*_example/**" }
		files { "null_example/*.h", "null_example/*.cpp", "./README.txt" }
		filter { "system:windows" }
			ignoredefaultlibraries { "msvcrt" }
end

-- sdl_opengl2_example (SDL + OpenGL2)
if (_OPTIONS["with-sdl"]) then
	project "sdl_opengl2_example"
		kind "ConsoleApp"
		imgui_as_src ("..", "imgui")
		--imgui_as_lib ("..")
		vpaths { ["sources"] = "*_example/**" }
		files { "sdl_opengl2_example/*.h", "sdl_opengl2_example/*.cpp", "./README.txt" }
		includedirs { "%SDL2_DIR%/include" }
		filter { "system:windows", "platforms:x86" }
			libdirs { "%SDL2_DIR%/lib/x86" }
		filter { "system:windows", "platforms:x86_64" }
			libdirs { "%SDL2_DIR%/lib/x64" }
		filter { "system:windows" }
			ignoredefaultlibraries { "msvcrt" }
			links { "SDL2", "SDL2main", "opengl32" }
end

-- sdl_opengl3_example (SDL + OpenGL3)
if (_OPTIONS["with-sdl"]) then
	project "sdl_opengl3_example"
		kind "ConsoleApp"
		imgui_as_src ("..", "imgui")
		--imgui_as_lib ("..")
		vpaths { ["sources"] = "*_example/**", ["libs/gl3w/GL"] = "libs/gl3w/GL/**" }
		files { "sdl_opengl3_example/*.h", "sdl_opengl3_example/*.cpp", "./README.txt", "libs/gl3w/GL/gl3w.c" }
		includedirs { "%SDL2_DIR%/include", "libs/gl3w" }
		filter { "system:windows", "platforms:x86" }
			libdirs { "%SDL2_DIR%/lib/x86" }
		filter { "system:windows", "platforms:x86_64" }
			libdirs { "%SDL2_DIR%/lib/x64" }
		filter { "system:windows" }
			ignoredefaultlibraries { "msvcrt" }
			links { "SDL2", "SDL2main", "opengl32" }
end

-- vulkan_example (GLFW + Vulkan)
if (_OPTIONS["with-vulkan"]) then
	project "vulkan_example"
		kind "ConsoleApp"
		imgui_as_src ("..", "imgui")
		--imgui_as_lib ("..")
		vpaths { ["sources"] = "*_example/**" }
		files { "vulkan_example/*.h", "vulkan_example/*.cpp", "./README.txt" }
		includedirs { "libs/glfw/include", "%VULKAN_SDK%/include" }
		filter { "system:windows", "platforms:x86" }
			libdirs { "libs/glfw/lib-vc2010-32", "%VULKAN_SDK%/lib32" }
		filter { "system:windows", "platforms:x86_64" }
			libdirs { "libs/glfw/lib-vc2010-64", "%VULKAN_SDK%/lib" }
		filter { "system:windows" }
			ignoredefaultlibraries { "msvcrt" }
			links { "vulkan-1", "glfw3" }
end
