#! /bin/bash

# dans cette fonction je cherche quelle action l'utilisateur veut performer
function selectOption() {
    filterNumber=0
    filter=0

    dashColor="\e[31m"
    numberColor="\e[33m"
    dotsColor="\e[32m"
    endColor="\e[0m"

    local option=$1

    case $option in
    -c | create)
        shift
        createListe "$@"
        ;;
    -s | show)
        checkForFiltrage "$@"
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
        echo "Usage: todo [OPTIONS] [LIST] [INDEX|ITEM]"
        echo "Try todo 'help or -h' for more informations"
        exit 1
        ;;
    esac
}

#### create OPTION ####

function createListe() {
    createHandling "$1"
    local nameOfList=$1

    touch "$nameOfList"
    echo "La Liste $nameOfList est crée"
}

#### erase OPTION ####

function eraseListe() {
    eraseHandling "$1"
    local nameOfList=$1

    rm "$nameOfList"
    echo "La Liste $nameOfList est supprimée"
}

#### show OPTION ####
function checkForFiltrage() {
    shift 2
    local OPTIND
    while getopts :n: flag; do
        case $flag in
        n)
            if [[ -z $OPTARG || $OPTARG = " " ]]; then
                echo "l'argument du flag $flag est une chaîne vide"
                exit 1
            fi
            filterNumber=$OPTARG
            filter=1
            ;;
        :)
            echo "No options were passed for the flag $OPTARG"
            exit 1
            ;;
        \?) ;;

        esac

    done
}

function filterDisplay() {
    local i=1
    while read -r line; do
        echo -e "${numberColor}${i} ${dotsColor}|->${endColor} $line"
        ((i++))
        if [[ i -gt filterNumber ]]; then
            break
        fi
    done <"$nameOfList"
}

function showListe() {
    showHandling "$1"
    nameOfList=$1
    # je teste si la liste est vide
    if [[ ! -s "$nameOfList" ]]; then
        echo " -- "
        echo "(  )"
        echo " -- "
    elif [[ "$filter" -eq 1 ]]; then

        filterDisplay "$@"
    else
        # si la liste n'est pas vide et pas de filtrage je fais appel a la fonction displayList
        displayList "$1"
    fi
}
# cette fonction va m'aider à résoudre le problème d'un fichier qui contient plus de 10 ligne parceque les nombres < 10 prend qu'un seul espace alors que >10 prend 2 espace
function calcNumberOfLines() {
    # la variable numberOfLines va me permettre de stocker le nombre de ligne d'un fichier
    numberOfLines=0
    while read -r line; do
        # chaque fois j'incrémente la variable numberOfLines jusqu'à ce que le fichier est parcouru
        ((numberOfLines++))
    done <"$1"
}

function calcUppAndDown() {
    # la variable longestTask va me permettre de stocker la longeur de la plus long tâche
    local longestTask=0
    # je parcours le fichier qui porte le même nom que la liste ligne par ligne par la fonction read
    while read -r line; do
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
    # pour savoir le nombre de tirets a afficher je fais appel a la fonction calcUppAndDown
    calcUppAndDown "$1"
    echo -en " ${dashColor}"
    local i=0
    # je printe les tirets
    for ((i; i < "$uppAndDown"; i++)); do
        echo -n "-"
    done
    echo -e " ${endColor}"
}

function displayList() {
    # afficherTiret permet d'afficher les tirets (-------) qui fait part de l'affichage mais avec une facon dynamique
    afficherTiret "$1"
    #la variable i va me permettre de sauvgarder l'indece de chaque tâche
    local i=1

    while read -r line; do
        # j'affiche la premier partie de la ligne qui présente la tâche
        echo -en "(  ${numberColor}${i}${dotsColor}.${endColor} $line"
        # je teste si j'arrive à la ligne numéro 10
        if [[ "$i" -le 9 ]]; then
            # toujours du calcul mathématique pour avoir un affichage disant parfait
            local reste=$((uppAndDown - ${#line} - 5))
        else
            local reste=$((uppAndDown - ${#line} - 6))
        fi
        # la variable reste va me permettre de stocker le nombre d'espace que je dois printer avant la ")"
        # j'affiche la deuxiéme partie de la ligne qui présente la tâche
        local j=0
        for ((j; j < reste; j++)); do
            echo -n " "
        done
        echo ")"
        ((i++))
    done <"$nameOfList"

    afficherTiret "$1"
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
#### sort Functions ####

function eraseDuplicateValues() {
    # cette fonction va me permettre d'éleminer les éléments dupliquées (1 2 2 3) devient (1 2 3)
    local array=("$@")
    #printf permet de lister les différentes indexs dans la variable array(-u pour éleminer les éléments dupliquées)
    unique=($(printf "%s\n" "${array[@]}" | sort -u))
}

function calcReversedSortedArr() {
    # cette fonction va me permettre d'avoir un tableau d'indices trier d'une facon inverse (3 5 1) devient (5 3 1)
    local array=("$@")
    # (-r pour trier d'une facon inverse)
    reversedSortedArr=($(printf "%s\n" "${array[@]}" | sort -r))
}

function calcSortedArr() {
    # cette fonction va me permettre d'avoir un tableau d'indices trier d'une facon (3 5 1) devient (1 3 5)
    local array=("$@")
    sortedArr=($(printf "%s\n" "${array[@]}" | sort))
}

#### done OPTION ####

function doneInListe() {
    doneHandling "$@"
    local nameOfList=$1
    shift
    # la fonction eraseDuplicateValues va me permettre de résoudre un probléme de suppression parceque par exemple si l'un des indices est dupliquée (2 2) alors aprés que je supprime la ligne d'indice 2 je vais supprimer la ligne d'indice 3 aussi car son indice devient 2
    eraseDuplicateValues "$@"
    # le fonction calcReversedSortedArr va me permettre de résoudre un probléme de suppression parceque par exemple si les indices des lignes a supprimer sont 1 5 alors si je commence par supprimer la ligne 1 la ligne d'indice 5 va changer l'indice a 4
    calcReversedSortedArr "${unique[@]}"
    for index in "${reversedSortedArr[@]}"; do
        # je boucle sur le tableau d'indices et je supprime la ligne correspondant (le d dans la fonction sed permet de supprimer et i de faire une modification permanentes)
        sed -i "${index}d" "$nameOfList"
        echo "la tâche d'indice : \"$index\" est supprimée de la liste $nameOfList "
    done
}

#### move OPTION ####

# la fonction moveTask utilise les deux fonctions doneInListe et addToListe pour déplacer une tâche d'une liste a une autre
function moveTask() {
    moveHandling "$@"
    local nameOfFirstList=$1
    local nameOfSecondList=$2
    # la fonction doneInListe travaille avec des indices alors que la fonction addToListe travaille avec des chaînes de caractéres alors il faut trouver la chaine de caractére qui correspend à chaque indice
    # deux shift pour garder que les indices
    shift 2
    # je fais appel a la fonction calcSortedArr pour m'aider a enregistrer les tâches à déplacer dans la variable tasksToMove
    eraseDuplicateValues "$@"
    calcSortedArr "${unique[@]}"
    # j'ai trier les indices passer comme arguments pour que je puisse enregistrer tout les tâches
    declare -a tasksToMove
    # la variable i présente l'indice
    local i=1
    # la variable j présente l'indice du tableau sortedArr
    local j=0

    while read -r line; do
        # je teste si l'indice de la ligne égale a l'un des indices dans la variable sortedArr
        if [[ "$i" -eq ${sortedArr[$j]} ]]; then
            # j'ajoute la ligne qui correspend a l'indice au variable tasksToMove
            tasksToMove[${#tasksToMove[@]}]=$line
            ((j++))
        fi

        ((i++))
    done <"$nameOfFirstList"

    # j'ai le choix de faire la suppression avant l'addition vice versa
    addToListe "$nameOfSecondList" "${tasksToMove[@]}"
    calcReversedSortedArr "${unique[@]}"
    doneInListe "$nameOfFirstList" "${reversedSortedArr[@]}"
}

#### help OPTION ####
# une fonction qui va permettre d'afficher un manuel de la commande ./todo.sh
function displayHelp() {
    printf "@Usage: todo [OPTIONS] [LIST] [INDEX|ITEM]

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
    todo create list5
            Create list under the name list5.
    todo -a list5 \"Something to do\"
            add \"Something to do\" to list5
    todo show list5
            list all the task in the list5.
"
}

#### Exception Handling ####
function createHandling() {
    if [[ -d "$1" ]]; then
        echo "Un Dossier existe déja sous le nom $1" >&2
        exit 1
    elif [[ -f "$1" && -s "$1" ]]; then
        echo "Un fichier non vide sous le nom $1 existe déja" >&2
        exit 1
    elif [[ -z "$1" || $1 = " " ]]; then
        echo "l'un des arguments est une chaîne vide"
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
    # tester si l'un des arguments est une chaîne vide ou contient qu'un espace
    for task in "$@"; do
        if [[ -z "$task" || $task = " " ]]; then
            echo "l'un des arguments est une chaîne vide"
            exit 1
        fi
    done
}

function doneHandling() {
    fileExistOrIsDirectory "$1"
    calcNumberOfLines "$1"

    shift

    checkArguments "$@"
    checkIndexType "$@"
    checkIndexInRange "$@"
}

function moveHandling() {
    fileExistOrIsDirectory "$1"
    fileExistOrIsDirectory "$2"
    calcNumberOfLines "$1"

    shift 2

    checkArguments "$@"
    checkIndexType "$@"
    checkIndexInRange "$@"
}
#la fonction fileExistOrIsDirectory permet de savoir si la liste passer comme argument existe
function fileExistOrIsDirectory() {
    if [[ ! -e "$1" ]]; then
        echo "la liste \"$1\" n'existe pas" >&2
        exit 1
    elif [[ -d "$1" ]]; then
        echo "la liste \"$1\" est actuellement un dossier" >&2
        exit 1
    fi
}
# la fonction checkArguments permet de savoir si l'utilisateur a passée au moins un indice
function checkArguments() {
    if [[ "$#" -eq 0 ]]; then
        echo "vous devez entrer au moins un indice comme argument" >&2
        exit 1
    fi
}
# la fonction checkIndexInRange permet de savoir si l'un des indices passer comme argument ne se trouve pas dans la liste
function checkIndexInRange() {
    for index in "$@"; do
        if [[ "$index" -gt $numberOfLines ]]; then
            echo "Aucun tâche ne correspond à l'indice : \"$index\" "
            exit 1
        fi
    done
}
# la fonction checkIndexType permet de savoir si l'un des arguments est une chaîne de caractères
function checkIndexType() {
    local re='^[0-9]+$'
    for index in "$@"; do
        if ! [[ "$index" =~ $re ]]; then
            echo "l'indice : \"$index\" est une chaîne de caractères et non pas un entier"
            exit 1
        fi
    done
}

####  MAIN ####
#--------------------------------------------------
# dès que l'utilisateur tappe une commande la premiére fonction qui s'execute est selectOption
# chaque fonction qui se termine par Handling a pour but de gérer les erreurs
selectOption "$@"
#--------------------------------------------------
