#! python3
#-------------------------------------------------------------------------------

import os
import sys
import tempfile
import shutil
import asyncio

#-------------------------------------------------------------------------------

def infomsg(msg):
    print(msg, flush=True)

#-------------------------------------------------------------------------------

async def execute_cmdline(cmdline, dotnetenv):
    #dotnetenv = {}
    #dotnetenv["DOTNET_CLI_UI_LANGUAGE"] = "en-us"
    myencoding = None

    infomsg("executing cmdline -> " + " ".join(cmdline))

    process = await asyncio.create_subprocess_exec(
        *cmdline,
        stdout=asyncio.subprocess.PIPE,
        stderr=asyncio.subprocess.PIPE,
        env=dotnetenv
    )

    stdout, stderr = await process.communicate()

    if process.returncode != 0:
        raise RuntimeError(f"Command '{' '.join(cmdline)}' failed with exit status {process.returncode}")

    if stdout:
        infomsg(stdout.decode(myencoding or 'utf-8').strip())
    if stderr:
        infomsg(stderr.decode(myencoding or 'utf-8').strip())

#-------------------------------------------------------------------------------

async def main():
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
        dotnetenv["DOTNET_CLI_TELEMETRY_OPTOUT"]="true"
        dotnetenv["DOTNET_GENERATE_ASPNET_CERTIFICATE"]="false"
        dotnetenv["DOTNET_CLI_FORCE_UTF8_ENCODING"]="true"
        dotnetenv["DOTNET_SYSTEM_NET_DISABLEIPV6"]="true"
        
        infomsg("Creating skeleton console application")
        cmdline = ["dotnet","new","console","--use-program-main"]
        await execute_cmdline(cmdline,dotnetenv)
        
        infomsg("Running the application")
        cmdline = ["dotnet","run"]
        await execute_cmdline(cmdline,dotnetenv)
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
    asyncio.run(main())

#-------------------------------------------------------------------------------
