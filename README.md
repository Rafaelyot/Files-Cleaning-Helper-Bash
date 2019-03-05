# Files-Cleaning-Helper-Bash
Bash scripts to help a linux user dealing with management of files 
## Description
Those two bash scripts allows the listing of files according to the chosen option
## Usage
"Usage: totalspace.sh [OPTION]... [DIRECTORY(s)]"
    At least ONE directory must be passed
    Options:
    		-a: Sort alphabetically
    		-r: Sort in reverse order
    		-d [date]: Maximum file access date
    		-l [int]: Number of the biggest files to be consider in each directory
    		-L [int]: Number of the biggest files to be consider in all directories
    		-n [regex expression]: Consider only files that match the specified regex expression
"Usage: nespace.sh [OPTION]... [DIRECTORY(s)]"
    At least ONE directory must be passed
    Options:
            -All options above
            -e [file name(path)]: Consider only files that are not included in the specified file
Warning: -l and -L cant be selected simultaneously,other combinations are possible


