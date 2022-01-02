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
    esac
}

function createListe() {
    nameOfList=$1

    touch "$nameOfList"
    echo "La Liste $nameOfList est crée"
}

function eraseListe() {
    nameOfList=$1

    rm "$nameOfList"
    echo "La Liste $nameOfList est supprimée"
}

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

    while read -r line || [ -n "$line" ]; do
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

function addToListe() {
    nameOfList=$1
    calcNumberOfLines "$@"
    shift
    if [[ $((numberOfLines + $#)) -ge 10 ]]; then
        echo "Le Nombre limite de tasks dans chacun liste est 9 tasks"
        return 1
    fi
    for task in "$@"; do
        echo "$task" >>"$nameOfList"
        echo "la task : \"$task\" est ajoutée "
    done
}

function calcNumberOfLines() {
    numberOfLines=0
    while read -r line || [ -n "$line" ]; do
        numberOfLines=$((numberOfLines + 1))
    done <"$nameOfList"
}

####MAIN####
#--------------------------------------------------
selectOption "$@"
#--------------------------------------------------
