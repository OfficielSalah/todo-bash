#! /bin/bash

option=$1

function selectOption() {
    case $option in
    create)
        shift
        create "$@"
        ;;
    show) showListe ;;
    add) addToListe ;;
    done) doneInListe ;;
    rm) removeFromListe ;;
    erase) eraseListe ;;
    esac
}
function displayList() {
    nameOfList=$1
    maxDistance=0

    numberOfLines=$(wc -l "$1")
    echo " "
    for ((i = 0; i < "$numberOfLines"; i++)); do
        echo "-"
    done
    echo " "

    while read line; do
        echo "$line"
        echo "$line" | wc -c
        numberOfWords=$(wc -w "$1")
        echo "$(wc)"
    done <"$1"
}

: '
function addToListe() {
}
function doneInListe() {
}
'

####MAIN####
#--------------------------------------------------
selectOption "$@"
#--------------------------------------------------
