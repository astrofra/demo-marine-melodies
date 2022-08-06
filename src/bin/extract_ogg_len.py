# D:\projects\demos\git_demo-minisub-escape\demo\bin\sox>sox.exe --i ..\..\assets\audio\aceman_underwater.ogg
import os
import subprocess

def main():
    print(os.getcwd())
    audio_path = 'assets\\audio'
    # audio_path = '..\\..\\assets\\audio'
    # open output lua file
    with open('songs_data.lua', 'w') as out:
        out.write('-- this table is generated, do not touch it!\n\n')
        out.write('local songs_data = {\n')
        # get list of ogg files
        files = os.listdir(audio_path)
        for ogg_file in files:
            ogg_path = audio_path + '\\' + ogg_file
            print(ogg_path)
            cmd_line = ['bin\\sox\\sox.exe', '--i', ogg_path]
            result = subprocess.run(cmd_line, stdout=subprocess.PIPE)
            r = result.stdout.decode()
            r = r.split('\n')
            print(r)
            for line in r:
                if line.startswith('Sample Rate'):
                    v = line.replace('Sample Rate', '')
                    v = v.replace(' ', '')
                    v = v.replace(':', '')
                    v = v.strip()
                    v = int(v)

                    out.write('\t' + ogg_file.replace('.ogg', '') + ' = {\n')
                    out.write('\t\tfrequency = ' + str(v) + ',\n')

                if line.startswith('Duration'):
                    v = line.replace('Duration', '')
                    v = line.replace('samples', '')
                    v = v.replace(' ', '')
                    v = v.replace(':', '')
                    v = v.strip()
                    v = v[v.find("=") + 1:]
                    v = v[:v.find("=")]
                    v = int(v)
                    out.write('\t\tsamples = ' + str(v) + ',\n')
                    out.write('\t},\n')


        out.write('}\n\n')
        out.write('return songs_data\n')
        out.close()

main()