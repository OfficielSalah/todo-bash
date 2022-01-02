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

    while read line; do
        if [[ "${#line}" -gt $longestTask ]]; then
            longestTask=${#line}
        fi
    done <"$1"

    uppAndDown=$((longestTask + 7))
}

function afficherTiret() {
    echo -n " "
    calcUppAndDown "$@"
    for ((i = 0; i < "$uppAndDown"; i++)); do
        echo -n "-"
    done
    echo " "
}

function displayList() {
    afficherTiret "$@"

    local i=1

    while read line; do
        echo -n "(  ${i}. $line"
        for ((j = 0; j < $((uppAndDown - ${#line} - 5)); j++)); do
            echo -n " "
        done
        echo ")"
        i=$((i + 1))
    done <"$1"

    afficherTiret "$@"
}

function addToListe() {
}

####MAIN####
#--------------------------------------------------
selectOption "$@"
#--------------------------------------------------
