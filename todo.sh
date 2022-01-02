#! /bin/bash

option=$1

function selectOption() {
    case $option in
    create)
        shift
        createListe "$@"
        ;;
    show)
        shift
        showListe "$@"
        ;;
    add)
        shift
        addToListe "$@"
        ;;
    done)
        shift
        doneInListe "$@"
        ;;
    erase)
        shift
        eraseListe "$@"
        ;;
    help)
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

    uppAndDown=$((longestTask + 7))
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
        local reste=$((uppAndDown - ${#line} - 5))
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
    calcNumberOfLines
    shift
    if [[ $((numberOfLines + $#)) -ge 10 ]]; then
        echo "Le Nombre limite des tâches dans chaque liste est 9 tasks"
        return 1
    fi
    for task in "$@"; do
        echo "$task" >>"$nameOfList"
        echo "la tâche : \"$task\" est ajoutée à la liste $nameOfList"
    done
}

function calcNumberOfLines() {
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
    echo "help"
}

####MAIN####
#--------------------------------------------------
selectOption "$@"
#--------------------------------------------------
