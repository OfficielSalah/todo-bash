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
    rm)
        shift
        removeFromListe "$@"
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

function eraseListe() {
    nameOfList=$1
    rm "$nameOfList"
    echo "La Liste $nameOfList est supprimée"
}

function afficherTiret() {

    echo -n " "
    for ((i = 0; i < "$uppAndDown"; i++)); do
        echo -n "-"
    done
    echo " "
}

function calcUppAndDown() {
    nameOfList=$1
    local longestTask=0

    while read line; do
        if [[ "${#line}" -gt $longestTask ]]; then
            longestTask=${#line}
        fi
    done <"$1"

    uppAndDown=$((longestTask + 5))
    return uppAndDown

}

function displayList() {
    afficherTiret "$@"

    i=1

    while read line; do
        echo "(  ${i}. $line )"
        i=$((i + 1))
    done <"$1"

    afficherTiret "$@"
}

####MAIN####
#--------------------------------------------------
selectOption "$@"
#--------------------------------------------------
