#! /bin/bash

# dans cette fonction je cherche quelle action l'utilisateur veut performer
function selectOption() {
    local option=$1
    case $option in
    -c | create)
        shift # shift permet de faire sauter un argument
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

#### create OPTION ####

function createListe() {
    createHandling "$@"
    local nameOfList=$1

    touch "$nameOfList"
    echo "La Liste $nameOfList est crée"
}

#### erase OPTION ####

function eraseListe() {
    eraseHandling "$@"
    local nameOfList=$1

    rm "$nameOfList"
    echo "La Liste $nameOfList est supprimée"
}

#### show OPTION ####

function showListe() {
    showHandling "$@"
    nameOfList=$1
    # je teste si le liste est vide
    if [[ ! -s "$nameOfList" ]]; then
        echo " -- "
        echo "(  )"
        echo " -- "
    else
        # si la liste n'est pas vide je fais appel a la fonction displayList
        displayList "$@"
    fi
}
# cette fonction va m'aider à résoudre le problème d'un fichier qui contient plus de 10 ligne parceque les nombres < 10 prend qu'un seul espace alors que >10 prend 2 espace
function calcNumberOfLines() {
    # la variable numberOfLines va me permettre de stocker le nombre de ligne dans le fichier (numberOfLines initialisée a 0)
    numberOfLines=0
    while read -r line; do
        # chaque fois j'incrémente la variable numberOfLines jusqu'à ce que le fichier est parcoru
        numberOfLines=$((numberOfLines + 1))
    done <"$1"
}

function calcUppAndDown() {
    # la variable longestTask va me permettre de stocker la longeur de la plus long tâche (longestTask initialisée a 0)
    local longestTask=0
    # je parcours le fichier qui porte le même nom que la liste ligne par ligne par la fonction read
    while read -r line || [ -n "$line" ]; do
        # si la longeur de la ligne courant est plus grand que la variable longestTask je change la variable longestTask
        if [[ "${#line}" -gt $longestTask ]]; then
            longestTask=${#line}
        fi
    done <"$nameOfList"
    # je fais appel a la fonction calcNumberOfLines pour résoudre un probléme d'affichage lorsque le nombre de lignes dépasse 9 ligne
    calcNumberOfLines "$@"
    # je test si le nombre de ligne >10
    if [[ "$numberOfLines" -ge 10 ]]; then
        # aprés un calcul mathématique il faut ajouter 8
        uppAndDown=$((longestTask + 8))
    else
        uppAndDown=$((longestTask + 7))
    fi
}

function afficherTiret() {
    echo -n " "
    # pour savoir le nombre de tirets a afficher je fais appel a la fonction calcUppAndDown
    calcUppAndDown "$@"
    local i=0
    # je printe les tirets
    for ((i; i < "$uppAndDown"; i++)); do
        echo -n "-"
    done
    echo " "
}

function displayList() {
    # afficherTiret permet d'afficher les tirets (-------) qui fait part de l'affichage mais avec une facon dynamique
    afficherTiret "$@"
    #la variable i va me permettre de sauvgarder l'indece de chaque tâche
    local i=1

    while read -r line; do
        # j'affiche la premier partie de la ligne qui présente la tâche
        echo -n "(  ${i}. $line"
        # je teste si j'arrive à la ligne numéro 10
        if [[ "$i" -le 9 ]]; then
            # toujours du calcul mathématique pour avoir un affichage disant parfait
            local reste=$((uppAndDown - ${#line} - 5))
        else
            local reste=$((uppAndDown - ${#line} - 6))
        fi
        # la variable reste va me permettre de stocker le nombre d'espace que je dois printer avant la )
        local j=0
        for ((j; j < reste; j++)); do
            echo -n " "
        done
        echo ")"
        i=$((i + 1))
    done <"$nameOfList"

    afficherTiret "$@"
}

#### add OPTION ####

function addToListe() {
    addHandling "$@"
    local nameOfList=$1
    # je fais un shift pour garder que les tâches à ajouter
    shift
    for task in "$@"; do
        echo "$task" >>"$nameOfList"
        echo "la tâche : \"$task\" est ajoutée à la liste $nameOfList"
    done
}

#### done OPTION ####

function calcReversedSortedArr() {
    # cette fonction va me permettre d'avoir un tableau d'indices trier d'une facon inverse (3 5 1) devient (5 3 1)
    array=("$@")
    # printf permet de lister les différentes indexs dans la variable array (-r pour trier d'une facon inverse)
    reversedSortedArr=($(printf "%s\n" "${array[@]}" | sort -r))
}
function doneInListe() {
    doneHandling "$@"
    local nameOfList=$1
    shift
    # le fonction calcReversedSortedArr va me permettre de résoudre un probléme de suppression parceque par exemple si les indices des lignes a supprimer sont 1 5 alors si je commence par supprimer la ligne 1 la ligne d'indice 5 va changer l'indice a 4
    calcReversedSortedArr "$@"
    for index in "${reversedSortedArr[@]}"; do
        # je boucle sur le tableau d'indices et je supprime la ligne correspondant (le d dans la fonction sed permet de supprimer et i de faire une modification permanentes)
        sed -i "${index}d" "$nameOfList"
        echo "la tâche d'index : \"$index\" est supprimée de la liste $nameOfList "
    done
}

#### move OPTION ####

function calcSortedArr() {
    array=("$@")
    sortedArr=($(printf "%s\n" "${array[@]}" | sort))
}
# la fonction moveTask utilise les deux fonctions doneInListe et addToListe pour déplacer une tâche d'une liste a une autre
function moveTask() {
    moveHandling "$@"
    local nameOfFirstList=$1
    local nameOfSecondList=$2
    # la fonction doneInListe travaille avec des indices alors que la fonction addToListe travaille avec des chaînes de caractéres alors il faut trouver la chaine de caractére qui correspend à chaque indice
    # deux shift pour garder que les indices
    shift
    shift
    # je fais appel a la fonction calcSortedArr pour m'aider a enregistrer les tâches à déplacer dans la variable tasksToMove
    calcSortedArr "$@"

    declare -a tasksToMove
    # la variable i présente l'indice
    local i=1
    # la variable j présente l'indice du tableau sortedArr
    local j=0
    # j'ai trier les indices passer comme arguments pour que je puisse enregistrer tout les tâches
    while read -r line; do
        # je teste si l'indice de la ligne égale a l'un des indices dans la variable sortedArr
        if [[ "$i" -eq ${sortedArr[$j]} ]]; then
            # j'ajoute la ligne qui correspend a l'indice au variable tasksToMove
            tasksToMove[${#tasksToMove[@]}]=$line
            j=$((j + 1))
        fi

        i=$((i + 1))
    done <"$nameOfFirstList"
    # j'ai le choix de faire la suppression avant l'addition vice versa
    addToListe "$nameOfSecondList" "${tasksToMove[@]}"

    calcReversedSortedArr "$@"

    doneInListe "$nameOfFirstList" "${reversedSortedArr[@]}"

}

#### help OPTION ####
# une fonction qui va permettre d'afficher un manuel de la commande ./todo.sh
function displayHelp() {
    printf "@Usage: ./todo.sh [OPTIONS] [LIST] [INDEX|ITEM]

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
    ./todo.sh create list5
            Create list under the name list5.
    ./todo.sh -a list5 \"Something to do\"
            add \"Something to do\" to list5
    ./todo.sh show list5
            list all the task in the list5.
"
}

#### Exception Handling ####
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
    for task in "$@"; do
        if [[ -z "$task" ]]; then
            echo "l'un des arguments est une chaîne vide"
            exit 1
        fi
    done
    checkArguments "$@"
}

function doneHandling() {
    fileExistOrIsDirectory "$1"
    calcNumberOfLines "$1"

    shift

    checkIndexInRange "$@"
    checkArguments "$@"
}

function moveHandling() {
    fileExistOrIsDirectory "$1"
    fileExistOrIsDirectory "$2"
    calcNumberOfLines "$1"

    shift
    shift

    checkIndexInRange "$@"
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
        echo "vous devez entrer au moins un indice comme argument" >&2
        exit 1
    fi
}

function checkIndexInRange() {
    for index in "$@"; do
        if [[ "$index" -gt $numberOfLines ]]; then
            echo "Aucun tâche ne correspond à l'indice : \"$index\" "
            exit 1
        fi
    done
}

####  MAIN ####
#--------------------------------------------------
# dès que l'utilisateur tappe une commande la premiére fonction qui s'execute est selectOption
# chaque function qui se termine par Handling a pour but de gérer les erreurs
selectOption "$@"
#--------------------------------------------------
