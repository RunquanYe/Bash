#!/bin/bash
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Author:Runquan Ye
# Created Time: 2022/August/12
# Script Description: Write a useful file management Bash Script for renaming a series of files and creating dummy files in a convenient way for the developing process.
# GitHub: https://github.com/RunquanYe
# Linkedin: https://www.linkedin.com/in/runquanye/
#----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

<< 'HowToRunComm'
1.How to Run Bash Script
    a. open terminal, go the script directory.
    b. chmod +x fileHelper.sh 
    c. ./fileHelper.sh (Options: -h, -v, -r, -c, -C) (Arguments)  
HowToRunComm


version=1.0.0

#***************************
# Display helpe method.
#***************************
showHelp(){
echo "Helper Method"
printf -- '*%.0s' {1..30}; printf '\n'
cat << EOF  
Usage: ./fileHelper -h, -v, -r <arguments>, -c <argument>, -C <argument>
The FileHelper Bash Script is for renaming a series of files and creating dummy files in a convenient way for the developing process.
  Options:
    -h,     Display helper message.
    
    -v,     Display script version.

    -r,     Rename series of same type files.(You can also just use -r without any argument, then it will go into read user input mode.)
                argument$1, a series of targeted rename files, (required, you must use comma \",\" or space as delimiter).
                argument$2, customized output files' name, (optional, default value: "File" ).
                argument$3, start ordinal number for the rename sequences, (optional, default value: 1).
    
    -c,     Generate a customized dummy test data file.
                argument$1, repeat one-line content, (optional, default value: "This is test content.").
                argument$2, number of times repeats the one-line content, (optional, default value: 20 ).
                argument$3, turn off line number(n/N/0), (optional).
                argument$4, customized output data file name, (optional, default value: "dummyTest.txt").
    
    -C,     Generate a series customized dummy test data files.
                argument$1, repeat one-line content, (optional, default value: "This is test content.").
                argument$2, number of times repeats the one-line content, (optional, default value: 20 ).
                argument$3, turn off line number(n/N/0), (optional).
                argument$4, customized output data file name, (optional, default value: "dummyTest.txt").
                argument$5, number of times generate dummy data files, (optional, default value: 5).
EOF
}



#****************************************************************************************************
# Rename a series of files with an ordinal number, so that directory could be more organized. 
# @argument: $1, a series of targeted rename files' name.
# @argument: $2, customized output serie files' name.
# @argument: $3, start ordinal number for the rename sequences. 
#****************************************************************************************************
renameFile(){
    declare -a _argList=("$@")
    
    _targetFile=""
    _newFileName=""
    _ordinalNumber=""
   
    if [[ ${#_argList[@]} -ge 0 ]]; then
        _targetFile=${_argList[0]}
        [[ -z "$_targetFile" ]] &&  printf "\033[34;1mInput Argument Error, Unvalid target file name. Please retry with a valid non-null string value. \033[0m\n"  && return 1

        if [ -z "${_argList[1]}" ]; then _newFileName="File"; printf "\033[34;1mInput Argument Error, Unvalid customized file name. Go with default output file name, \"File\". \033[0m\n"; else _newFileName=${_argList[1]}; fi
        
        if [[ ! "${_argList[2]}" =~ ^[0-9]+$ ]]; then
            _ordinalNumber=1
            printf "\033[34;1mInput Argument Error, Unvalid ordinal number. Go with default initial ordinal number, 1. \033[0m\n"
        else
            _ordinalNumber=$(expr ${_argList[2]} + 0)
            if (( _ordinalNumber < 1 )); then _ordinalNumber=1; printf "\033[34;1mInput Argument Error, Unvalid ordinal number. Go with default initial ordinal number, 1. \033[0m\n"; fi
        fi
    else
        echo "Please input the target file(s) you want to rename, please use comma \",\" to be delimiter."
        read target
        _targetFile=$target
        while [[ -z "$_targetFile" ]]; do
            echo "You inputed unvalid string value to be the target file name, please try again and use comma \",\" or space to be the delimiter."
            read -e target
            _targetFile=$target
        done

        echo "Please input the customize rename file name."
        read newName
        _newFileName=$newName
        while [[ -z "$_newFileName" ]]; do
            echo "You inputed unvalid string value to be the customized file name, please try again."
            read -e newName
            _newFileName=$newName
        done
        
        echo "Please input the start ordinal number." 
        read sequence
        while [[ ! $sequence =~ ^[0-9]+$ ]]; do
            echo "You inputed unvalid positive integer value to be the ordinal number, please try again."
            read -e sequence
        done
            (( _ordinalNumber = sequence + 0 ))
    fi
    
    _targetFileList=(`echo $_targetFile | tr ',' ' '`)
    echo "Rename $_targetFile to file series format, $( [[ ${_newFileName%.*} == ${_newFileName#*.} ]] && echo "$_newFileName"_X || echo "${_newFileName%.*}_X.${_newFileName#*.}" ):"

    for _file in "${_targetFileList[@]}"
    do
        if [[ -e $_file  ]]; then
            _new=$( [[ ${_newFileName%.*} == ${_newFileName#*.} ]] && echo "$_newFileName"_"$_ordinalNumber" || echo "${_newFileName%.*}_$_ordinalNumber.${_newFileName#*.}" )
            echo "rename file: $_file ==> $_new"
            mv -- "$_file" "$_new"
            (( _ordinalNumber += 1 ))
        else
            printf "\033[34;1mError, Unvalid target rename file, $_file, does not exist.\033[0m\n" 
        fi
    done
}


#*************************************************************************************************************************
# Create Dummy File for application testing.  User could customize the input content, repeat time and output file name. 
# @argument: $1, repeat one-line content.
# @argument: $2, number of times repeats the one-line content.
# @argument: $3, turn off line number(n/N/0). 
# @argument: $4, customized output data file name. 
#*************************************************************************************************************************
function createDummyFile () {
    _content=$( [[ ! -z $1 ]] && echo $1 || echo "This is test content." )
    _linNum=1

    [[ $3 == 'N' || $3 == 'n' || $3 == 0 ]] && _linNum=0 
    # let user input the content as $1, loop times as $2 and output file name as $3.
    printf "Generate a dummy test data files, ${4:-dummyTest.txt}\n"
    for (( i=0;i<${2:-20};i++ ))
    do 
        echo "$( [[ $_linNum == 1 ]] && echo "$(( $i+1 )): " )$_content" >> ${4:-dummyTest.txt}
    done 
}



#********************************************************************************************************************************************************************
# Create a series of dummy test file for application testing.  User could customize the input content, repeat time, output file name, and number of series files. 
# @argument: $1, repeat one-line content.
# @argument: $2, number of times repeats the one-line content.
# @argument: $3, turn off line number(n/N/0). 
# @argument: $4, customized output data file name. 
# @argument: $5, number of times generate dummy data files.
#********************************************************************************************************************************************************************
function createNumDummyFiles () {
    _content=$( [[ ! -z $1 ]] && echo $1 || echo "This is test content." )
    _linNum=1

    [[ $3 == 'N' || $3 == 'n' || $3 = 0 ]] && _linNum=0;  
     
    # let user input the content as $1, loop times as $2 and output file name as $3.
    printf "Generate a series of dummy test data files, ${4:-dummyTest.txt}\n"
    for (( f=1; f<=${5:-5}; f++ ))
    do    
        echo "  Generate No.$f test data file, $( [ -z $4 ] && echo "dummyTest_$f.txt" || echo "${4%.*}_$f.${4#*.}" )"
        for (( i=0;i<${2:-20};i++ ))
        do 
            echo "$( [[ $_linNum = 1 ]] && echo "$(( $i+1 )): " )$_content" >> $( [ -z $4 ] && echo "dummyTest_$f.txt" || echo "${4%.*}_$f.${4#*.}" )
        done 
    done
}



#**********************************
# Display programmer's profile.
#**********************************
displayProgrammerInfo(){
    printf -- '~%.0s' {1..79}; printf '\n'
    printf "\033[31;1mThank you for using my file assistent bash script. \033[33;1mHope you like it.\n\033[37;4mMore info about me, please visit my relative account pages.\033[0m\n"
    printf '\e]8;;https://github.com/RunquanYe\e\\\033[35;1m[GitHub]\033[0m\e]8;;\e\\'
    printf '\e]8;;https://github.com/RunquanYe/DemoProjects\e\\\033[33;1m[Demo Projects]\033[0m\e]8;;\e\\'
    printf '\e]8;;https://www.linkedin.com/in/runquanye\e\\\033[34;1m[Linkedin]\033[0m\e]8;;\e\\'
    printf "\n\033[37;7m==>Push Down (\033[31;7mWindows: Ctrl \033[37;7m|\033[34;7m Mac: Command \033[37;7m) key to enable above profile links.\033[0m\n"
    #echo -e '\e]8;;https://www.linkedin.com/in/runquanye\a[Linkedin Profile]\e]8;;\a'
    printf -- '~%.0s' {1..79}; printf '\n'
}


# if user does not provide any option, display help message.
[ $# -eq 0 ] && printf "\033[34;1mEmpty Command Option. Please look at the Help method below and try the valid option commands. \033[0m\n"  && showHelp

while getopts ":hvrcC" option; do
    case $option in
        h) # display Help.
            showHelp
            ;;
        v) # display script version.
            echo "Version = $version"
            ;;
        r) # call the renameFile funcation to rename series of same type files.
            argArray=("$2" $3 $4)
            renameFile "${argArray[@]}"
            ;;
        c) # call the createDummyFile to generate a dummy test data file.
            createDummyFile "$2" $3 $4 $5
            ;;
        C) # generate a series of dummy test data files.
            createNumDummyFiles "$2" $3 $4 $5 $6
            ;;
    esac
shift $((OPTIND-1))
done


# display my profile info at the end.
displayProgrammerInfo

# Exit the program
exit 0
