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
    createhandling "$@"
    local nameOfList=$1

    touch "$nameOfList"
    echo "La Liste $nameOfList est crée"
}

#### erase OPTION####

function eraseListe() {
    erasehandling "$@"
    local nameOfList=$1

    rm "$nameOfList"
    echo "La Liste $nameOfList est supprimée"
}

#### show OPTION####

function showListe() {
    showhandling "$@"
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
    nameOfList=$1
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
    done <"$1"

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
    done <"$1"

    afficherTiret "$@"
}

#### add OPTION####

function addToListe() {
    addhandling "$@"
    nameOfList=$1
    shift
    for task in "$@"; do
        echo "$task" >>"$nameOfList"
        echo "la tâche : \"$task\" est ajoutée à la liste $nameOfList"
    done
}

#### done OPTION####

function calcSortedArr() {
    array=("$@")

    IFS=$'\n'
    sortedArr=($(printf "%s\n" "${array[@]}" | sort -r))
    unset IFS
}
function doneInListe() {
    donehandling "$@"
    nameOfList=$1
    shift
    calcSortedArr "$@"
    for index in "${sortedArr[@]}"; do
        sed -i "${index}d" "$nameOfList"
        echo "la tâche d'index : $index est supprimée de la liste $nameOfList "
    done
}

#### help OPTION####

function displayHelp() {
    printf "@Usage: ./todo [OPTIONS] [LIST] [INDEX|ITEM]

@OPTIONS:
    -h,help This help message.
    -c,create Create a new list.
    -a,add Add an item to the list.
    -d,done Remove an item from the list by INDEX number.
    -e,erase Erase list.
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
function createhandling() {
    local nameOfList=$1
    if [[ -d "$nameOfList" ]]; then
        echo "Un Dossier existe déja sous le nom $nameOfList" >&2
        exit 1
    elif [[ -f "$nameOfList" && -s "$nameOfList" ]]; then
        echo "Un fichier sous le nom $nameOfList existe déja" >&2
        exit 1
    fi
}

function erasehandling() {
    local nameOfList=$1
    if [[ -d "$nameOfList" ]]; then
        echo "vous êtes en train de supprimer Un Dossier qui existe déja sous le nom $nameOfList" >&2
        exit 1
    fi
    fileExist "$@"
}

function showhandling() {
    local nameOfList=$1
    if [[ -d "$nameOfList" ]]; then
        echo "la liste \"$nameOfList\" est actuellement un dossier" >&2
        exit 1
    fi
    fileExist "$@"
}

function addhandling() {
    local nameOfList=$1
    if [[ -d "$nameOfList" ]]; then
        echo "vous êtes en train d'ajouter des élements a une liste sous le nom $nameOfList mais c'est le nom d'un dossier" >&2
        exit 1
    fi
    fileExist "$@"
    shift
    if [[ "$#" -le 0 ]]; then
        echo "vous devez au moins entrer une task comme argument" >&2
        exit 1
    fi
}

function donehandling() {
    local nameOfList=$1
    if [[ -d "$nameOfList" ]]; then
        echo "la liste \"$nameOfList\" est actuellement un dossier" >&2
        exit 1
    fi
    fileExist "$@"
    shift
    if [[ "$#" -le 0 ]]; then
        echo "vous devez au moins entrer un index comme argument" >&2
        exit 1
    fi
}

function fileExist() {
    local nameOfList=$1
    if [[ ! -e "$nameOfList" ]]; then
        echo "la liste \"$nameOfList\" n'existe pas" >&2
        exit 1
    fi
}

####MAIN####
#--------------------------------------------------
selectOption "$@"
#--------------------------------------------------
