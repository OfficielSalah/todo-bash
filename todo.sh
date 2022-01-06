#! /bin/bash

option=$1

function selectOption() {
    case $option in
    -c | create)
        shift
        createListe "$@"
        ;;
    -s | show)
        shift
        showListe "$@"
        ;;
    -a | add)
        shift
        addToListe "$@"
        ;;
    -d | done)
        shift
        doneInListe "$@"
        ;;
    -e | erase)
        shift
        eraseListe "$@"
        ;;
    -m | move)
        shift
        moveTask "$@"
        ;;
    -h | help)
        displayHelp
        ;;
    *)
        echo "Look at the help manuel because \"$option\" is not included in the options list"
        exit 1
        ;;
    esac
}

#### create OPTION####

function createListe() {
    createHandling "$@"
    local nameOfList=$1

    touch "$nameOfList"
    echo "La Liste $nameOfList est crée"
}

#### erase OPTION####

function eraseListe() {
    eraseHandling "$@"
    local nameOfList=$1

    rm "$nameOfList"
    echo "La Liste $nameOfList est supprimée"
}

#### show OPTION####

function showListe() {
    showHandling "$@"
    nameOfList=$1

    if [[ ! -s "$nameOfList" ]]; then
        echo " -- "
        echo "(  )"
        echo " -- "
    else
        displayList "$@"
    fi
}

function calcNumberOfLines() {
    numberOfLines=0
    while read -r line; do
        numberOfLines=$((numberOfLines + 1))
    done <"$nameOfList"
}

function calcUppAndDown() {
    local longestTask=0

    while read -r line || [ -n "$line" ]; do
        if [[ "${#line}" -gt $longestTask ]]; then
            longestTask=${#line}
        fi
    done <"$nameOfList"

    calcNumberOfLines "$@"

    if [[ "$numberOfLines" -ge 10 ]]; then
        uppAndDown=$((longestTask + 8))
    else
        uppAndDown=$((longestTask + 7))
    fi
}

function afficherTiret() {
    echo -n " "
    calcUppAndDown "$@"
    local i=0
    for ((i; i < "$uppAndDown"; i++)); do
        echo -n "-"
    done
    echo " "
}

function displayList() {
    afficherTiret "$@"

    local i=1

    while read -r line; do
        echo -n "(  ${i}. $line"
        if [[ "$i" -le 9 ]]; then
            local reste=$((uppAndDown - ${#line} - 5))
        else
            local reste=$((uppAndDown - ${#line} - 6))
        fi
        local j=0
        for ((j; j < reste; j++)); do
            echo -n " "
        done
        echo ")"
        i=$((i + 1))
    done <"$nameOfList"

    afficherTiret "$@"
}

#### add OPTION####

function addToListe() {
    addHandling "$@"
    local nameOfList=$1
    shift
    for task in "$@"; do
        echo "$task" >>"$nameOfList"
        echo "la tâche : \"$task\" est ajoutée à la liste $nameOfList"
    done
}

#### done OPTION####

function calcReversedSortedArr() {
    array=("$@")

    IFS=$'\n'
    reversedSortedArr=($(printf "%s\n" "${array[@]}" | sort -r))
    unset IFS
}
function doneInListe() {
    doneHandling "$@"
    local nameOfList=$1
    shift
    calcReversedSortedArr "$@"
    for index in "${reversedSortedArr[@]}"; do
        sed -i "${index}d" "$nameOfList"
        echo "la tâche d'index : \"$index\" est supprimée de la liste $nameOfList "
    done
}

#### move OPTION####

function calcSortedArr() {
    array=("$@")

    IFS=$'\n'
    sortedArr=($(printf "%s\n" "${array[@]}" | sort))
    unset IFS
}

function moveTask() {
    moveHandling "$@"
    local nameOfFirstList=$1
    local nameOfSecondList=$2

    shift
    shift

    calcSortedArr "$@"

    declare -a tasksToMove
    local i=1
    local j=0

    while read -r line; do
        if [[ "$i" -eq $((${sortedArr[$j]} + 0)) ]]; then
            tasksToMove[${#tasksToMove[@]}]=$line
            j=$((j + 1))
        fi

        i=$((i + 1))
    done <"$nameOfFirstList"

    addToListe "$nameOfSecondList" "${tasksToMove[@]}"

    calcReversedSortedArr "$@"

    doneInListe "$nameOfFirstList" "${reversedSortedArr[@]}"

}

#### help OPTION####

function displayHelp() {
    printf "@Usage: ./todo [OPTIONS] [LIST] [INDEX|ITEM]

@OPTIONS:
    -h,help Show help message.
    -c,create Create a new list.
    -e,erase Erase list.
    -a,add Add an item to the list.
    -d,done Remove an item from the list by INDEX number.
    -m,move Move task from list to the end of another list.
    -s,show Display the list.
@LIST:
    Name of list.
@INDEX:
    Integers:Index number of item.
@ITEM:
    String Todo ITEM.
@EXAMPLES:
    ./todo create list5
            Create list under the name list5.
    ./todo -a list5 \"Something to do\"
            add \"Something to do\" to list5
    ./todo show list5
            list all the task in the list5.
"
}

####Exception Handling####
function createHandling() {
    local nameOfList=$1
    if [[ -d "$nameOfList" ]]; then
        echo "Un Dossier existe déja sous le nom $nameOfList" >&2
        exit 1
    elif [[ -f "$nameOfList" && -s "$nameOfList" ]]; then
        echo "Un fichier sous le nom $nameOfList existe déja" >&2
        exit 1
    fi
}

function eraseHandling() {
    fileExistOrIsDirectory "$1"
}

function showHandling() {
    fileExistOrIsDirectory "$1"
}

function addHandling() {
    fileExistOrIsDirectory "$1"

    shift

    checkArguments "$@"
}

function doneHandling() {
    fileExistOrIsDirectory "$1"

    shift

    checkArguments "$@"
}

function moveHandling() {
    fileExistOrIsDirectory "$1"
    fileExistOrIsDirectory "$2"

    shift
    shift

    checkArguments "$@"
}

function fileExistOrIsDirectory() {
    local nameOfList=$1
    if [[ ! -e "$nameOfList" ]]; then
        echo "la liste \"$nameOfList\" n'existe pas" >&2
        exit 1
    fi
    if [[ -d "$nameOfList" ]]; then
        echo "la liste \"$nameOfList\" est actuellement un dossier" >&2
        exit 1
    fi
}

function checkArguments() {

    if [[ "$#" -le 0 ]]; then
        echo "vous devez entrer au moins un index comme argument" >&2
        exit 1
    fi
}

####MAIN####
#--------------------------------------------------
selectOption "$@"
#--------------------------------------------------
