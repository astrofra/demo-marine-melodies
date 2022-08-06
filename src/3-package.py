import os
import subprocess
import shutil

input_bin_path = "bin"
input_lua_path = "hg_lua-win-x64"
input_assets_path = "assetsc"
input_start_bat = "start-demo.bat"
input_nfo = "marine-melodies.nfo"
input_shot = "screenshot.png"
# input_start_bat_2 = "start-demo-low-specs.bat"

output_path = "../marine-melodies_resistance-2022"
output_lua_path = "engine"

try:
    os.mkdir(output_path)
except:
    print(output_path + " already exists!")

# compile lua files
files = os.listdir()
for _file in files:
    if _file.endswith(".lua"):
        cmd_line = [os.path.join(input_bin_path, input_lua_path, "luac"), "-s", "-o", os.path.join(output_path, _file), _file]
        print(cmd_line)
        result = subprocess.run(cmd_line, stdout=subprocess.PIPE)

# copy lua & harfang binaries
try:
    shutil.rmtree(os.path.join(output_path, output_lua_path), ignore_errors=False, onerror=None)
except:
    print("nothing to cleanup")
shutil.copytree(os.path.join(input_bin_path, input_lua_path), os.path.join(output_path, output_lua_path))

for _to_del in ["assimp_converter", "fbx_converter", "gltf_exporter", "gltf_importer", "assetc"]:
    shutil.rmtree(os.path.join(output_path, output_lua_path, "harfang", _to_del), ignore_errors=False, onerror=None)

os.remove(os.path.join(output_path, output_lua_path, "luac.exe"))

# copy assets
try:
    shutil.rmtree(os.path.join(output_path, input_assets_path), ignore_errors=False, onerror=None)
except:
    print("nothing to cleanup")
shutil.copytree(input_assets_path, os.path.join(output_path, input_assets_path))

# start.bat
try:
    os.remove(os.path.join(output_path, input_start_bat))
except:
    print("nothing to cleanup")
shutil.copy(input_start_bat, os.path.join(output_path, input_start_bat))

# .nfo
try:
    os.remove(os.path.join(output_path, input_nfo))
except:
    print("nothing to cleanup")
shutil.copy(input_nfo, os.path.join(output_path, input_nfo))

# screenshot
try:
    os.remove(os.path.join(output_path, input_shot))
except:
    print("nothing to cleanup")
shutil.copy(input_shot, os.path.join(output_path, input_shot))

