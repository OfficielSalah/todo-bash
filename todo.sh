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
    esac
}

#### create OPTION####

function createListe() {
    nameOfList=$1

    touch "$nameOfList"
    echo "La Liste $nameOfList est crée"
}

#### erase OPTION####

function eraseListe() {
    nameOfList=$1

    rm "$nameOfList"
    echo "La Liste $nameOfList est supprimée"
}

#### show OPTION####

function showListe() {
    nameOfList=$1

    if [[ ! -s "$nameOfList" ]]; then
        echo " -- "
        echo "(  )"
        echo " -- "
    else
        displayList "$@"
    fi
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
    nameOfList=$1
    calcNumberOfLines "$@"
    shift
    for task in "$@"; do
        echo "$task" >>"$nameOfList"
        echo "la tâche : \"$task\" est ajoutée à la liste $nameOfList"
    done
}

function calcNumberOfLines() {
    nameOfList=$1
    numberOfLines=0
    while read -r line; do
        numberOfLines=$((numberOfLines + 1))
    done <"$nameOfList"
}

#### done OPTION####

function calcSortedArr() {
    array=("$@")

    IFS=$'\n'
    sortedArr=($(printf "%s\n" "${array[@]}" | sort -r))
    unset IFS
}
function doneInListe() {
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

####MAIN####
#--------------------------------------------------
selectOption "$@"
#--------------------------------------------------
