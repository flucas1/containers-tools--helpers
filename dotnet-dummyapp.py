#! python3
#-------------------------------------------------------------------------------

import os
import sys
import subprocess
import tempfile
import shutil

#-------------------------------------------------------------------------------

def infomsg(msg):
    print(msg, flush=True)

#-------------------------------------------------------------------------------

def execute_cmdline(cmdline,dotnetenv):
    #dotnetenv = {}
    #dotnetenv["DOTNET_CLI_UI_LANGUAGE"] = "en-us"
    myencoding = None

    infomsg("executing cmdline -> "+" ".join(cmdline))
    completed = subprocess.run(cmdline, capture_output=True, encoding=myencoding, env=dotnetenv, check=True)
    infomsg(completed.stdout.decode().strip())
    infomsg(completed.stderr.decode().strip())

#-------------------------------------------------------------------------------

def main():
    errors = 0
    
    tempdir = None
    olddir = os.getcwd()

    try:
        infomsg("Creating temp folder")
        tempdir = tempfile.mkdtemp()
        infomsg("Changing path into "+tempdir)
        os.chdir(tempdir)
        
        dotnetenv = os.environ.copy()
        dotnetenv["NO_COLOR"]="true"
        dotnetenv["DOTNET_NOLOGO"]="true"
        dotnetenv["DOTNET_CLI_TELEMETRY_OPTOUT"]="1"
        dotnetenv["DOTNET_CLI_FORCE_UTF8_ENCODING"]="true"
        dotnetenv["DOTNET_SYSTEM_NET_DISABLEIPV6"]="true"
        
        infomsg("Creating skeleton console application")
        cmdline = ["dotnet","new","console","--use-program-main"]
        execute_cmdline(cmdline,dotnetenv)
        
        infomsg("Running the application")
        cmdline = ["dotnet","run"]
        execute_cmdline(cmdline,dotnetenv)
    except Exception as e:
        errors = errors+1
        infomsg(e)

    infomsg("Changing path into "+olddir)
    os.chdir(olddir)
    if os.path.isdir(tempdir):
        infomsg("Deleting "+tempdir)
        shutil.rmtree(tempdir)

    exitcode = 0
    if errors>0:
        exitcode = 1
    infomsg("The exitcode is "+str(exitcode))
    sys.exit(exitcode)

#-------------------------------------------------------------------------------

if __name__ == "__main__":
    main()

#-------------------------------------------------------------------------------
