#! /bin/bash

# des variables pour afficher la liste d'une facon filtrée
filterNumber=0
filter=0
# des variables pour ajouter une tache a un indice bien précis
addAt=0
indexAt=0
# des variables pour afficher la liste avec des couleurs
dashColor="\e[31m"
numberColor="\e[33m"
dotsColor="\e[32m"
endColor="\e[0m"

# dans cette fonction je cherche quelle action l'utilisateur veut performer
function selectOption() {
    local option=$1

    case $option in
    -c | --create)
        shift
        createListe "$@"
        ;;
    -e | --erase)
        shift
        eraseListe "$@"
        ;;
    -s | --show)
        checkForFiltrage "$@"
        shift
        showListe "$@"
        ;;
    -a | --add)
        checkForIndex "$@"
        shift
        addToList "$@"
        ;;
    -d | --done)
        shift
        doneInListe "$@"
        ;;
    -m | --move)
        shift
        moveTask "$@"
        ;;
    -h | --help)
        displayHelp
        ;;
    *)
        echo "Usage: todo [OPTIONS] LIST... [INDEX|ITEM]... [FLAG] [VALUE]"
        echo "Try todo '--help or -h' for more informations"
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

function showListe() {
    showHandling "$1"
    nameOfList=$1
    # je teste si la liste est vide
    if [[ ! -s "$nameOfList" ]]; then
        echo " -- "
        echo "(  )"
        echo " -- "
    elif [[ "$filter" -eq 1 ]]; then
        #si l'utilisateur veut faire un affichage filtrée je fais appel a la fonction filterDisplay
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
    # je fais appel a la fonction calcNumberOfLines pour résoudre un probléme d'affichage lorsque le nombre de lignes dépasse 9 lignes
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
    #la variable i va me permettre de sauvgarder l'indice de chaque tâche
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

#### filter OPTION ####

function checkForFiltrage() {
    #je saute les deux premier arguments qui présente l'option show et le nom de la liste
    shift 2
    #je vérifie si l'utilisateur veut faire un affichage avec filtrage en tapant le flag -n
    local OPTIND
    while getopts :n: flag; do
        case $flag in
        n)
            if [[ -z $OPTARG || $OPTARG = " " ]]; then
                echo "L'argument du flag $flag est une chaîne vide"
                exit 1
            elif [[ $OPTARG -eq 0 ]]; then
                echo "L'argument du flag $flag doit être supérieur à 0 pour faire l'affichage"
                exit 1
            fi
            checkIndexType "$OPTARG"
            filterNumber=$OPTARG
            filter=1
            ;;
        :)
            echo "Aucun argument est passée à l'option : $OPTARG"
            exit 1
            ;;
        \?)
            echo "Option invalide : \"-$OPTARG\""
            exit 1
            ;;

        esac

    done
}

function filterDisplay() {
    local i=1
    echo "->Affichage Filtrée à $filterNumber lignes"
    while read -r line; do
        #je donne des couleurs pour les indices et la fléche(-e permet d'intérprétée ce qui vient aprés \)
        echo -e "${numberColor}${i} ${dotsColor}|->${endColor} $line"
        ((i++))
        #si on arrive a la ligne indiqué par l'utilisateur on sort de la boucle
        if [[ i -gt filterNumber ]]; then
            break
        fi
    done <"$nameOfList"
}

#### add OPTION ####

function addToList() {
    if [[ "$addAt" -eq 1 ]]; then
        addToListWithIndex "$@"
    else
        addHandling "$@"
        local nameOfList=$1
        # je fais un shift pour garder que les tâches à ajouter
        shift
        for task in "$@"; do
            echo "$task" >>"$nameOfList"
            echo "La tâche : \"$task\" est ajoutée à la liste $nameOfList"
        done
    fi
}

#### atIndex option ####

function checkForIndex() {
    #je saute les deux premier arguments qui présente l'option add et le nom de la liste
    shift 2
    #je vérifie si l'utilisateur veut ajouter une tache à un indice bien précis
    local OPTIND
    while getopts :i: flag; do
        case $flag in
        i)
            if [[ -z $OPTARG || $OPTARG = " " ]]; then
                echo "L'argument du flag $flag est une chaîne vide"
                exit 1
            fi
            checkIndexType "$OPTARG"
            addAt=1
            indexAt=$OPTARG
            ;;
        :)
            echo "No options were passed to the flag $OPTARG"
            exit 1
            ;;
        \?)
            echo "Option invalide : \"-$OPTARG\""
            exit 1
            ;;

        esac

    done
}

function addToListWithIndex() {
    local nameOfList=$1
    fileExistOrIsDirectory "$1"

    shift
    #je verifie si l'utilisateur a fait passée la tache comme argument
    if [[ "$#" -lt 3 ]]; then
        echo "Vous devez entrer au moins un argument " >&2
        exit 1
    fi
    # je garde que la tache
    shift 2

    calcNumberOfLines "$nameOfList"
    ((numberOfLines++))

    if [[ $indexAt -gt $numberOfLines ]]; then
        echo "L'indice : \"$indexAt\" est plus grand que le nombre de lignes de la liste $nameOfList"
        exit 1
    elif [[ $indexAt -eq 0 ]]; then
        echo "L'indice : \"$indexAt\" doit être positive et plus grand que 0"
        exit 1
    elif [[ $indexAt -eq 1 ]]; then
        sed -i "1i$1" "$nameOfList"
        echo "La tache \"$1\" est ajoutée à la liste $nameOfList au début"
    else
        ((indexAt--))
        sed -i "${indexAt} a $1" "$nameOfList"
        echo "La tache \"$1\" est ajoutée à la liste $nameOfList à la ligne $((indexAt + 1))"
    fi
}
#### sort Functions ####

function eraseDuplicateValues() {
    # cette fonction va me permettre d'éleminer les éléments dupliquées (1 2 2 3) devient (1 2 3)
    local array=("$@")
    #printf permet de lister les différentes indices dans la variable array(-u pour éleminer les éléments dupliquées)
    unique=($(printf "%s\n" "${array[@]}" | sort -u))
}

function calcReversedSortedArr() {
    # cette fonction va me permettre d'avoir un tableau d'indices trier d'une facon inverse (3 5 1) devient (5 3 1)
    local array=("$@")
    # (-r pour trier d'une facon inverse)
    reversedSortedArr=($(printf "%s\n" "${array[@]}" | sort -nr))
}

function calcSortedArr() {
    # cette fonction va me permettre d'avoir un tableau d'indices trier d'une facon (3 5 1) devient (1 3 5)
    local array=("$@")
    sortedArr=($(printf "%s\n" "${array[@]}" | sort -n))
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
        echo "La tâche d'indice : \"$index\" est supprimée de la liste $nameOfList "
    done
}

#### move OPTION ####

# la fonction moveTask utilise les deux fonctions doneInListe et addToList pour déplacer une tâche d'une liste a une autre
function moveTask() {
    moveHandling "$@"
    local nameOfFirstList=$1
    local nameOfSecondList=$2
    # la fonction doneInListe travaille avec des indices alors que la fonction addToList travaille avec des chaînes de caractéres alors il faut trouver la chaine de caractére qui correspend à chaque indice
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
    addToList "$nameOfSecondList" "${tasksToMove[@]}"
    calcReversedSortedArr "${unique[@]}"
    doneInListe "$nameOfFirstList" "${reversedSortedArr[@]}"
}

#### help OPTION ####
# une fonction qui va permettre d'afficher un manuel de la commande ./todo.sh
function displayHelp() {
    printf "@Usage: todo [OPTIONS] LIST... [INDEX|ITEM]... [FLAG] [VALUE]

@OPTIONS:
    -h,--help | Show help message.
    -c,--create | Create a new list.
    -e,--erase | Erase list.
    -s,--show | Display the list.
    -a,--add | Add an item to the list.
    -d,--done | Remove an item from the list by INDEX number.
    -m,--move | Move task from list to the end of another list.
@LIST:
    Name of list.
@INDEX:
    Integers:Index number of item.
@ITEM:
    String Todo ITEM.
@FLAG:  Depends on the option
    -n | Filtring the display (display n lines)
    -i | Add task at a spisific index
@VALUE:
    integers
@EXAMPLES:
    todo --create list5
            Create list under the name list5.
    todo -a list5 \"Something to do\"
            add \"Something to do\" to list5
    todo --show list5
            list all the task in the list5.
    todo -s list5 -n 5
            display the fifth first lines on list5
    todo -a list5 -i 5 \"yeey\"
            add \"yeey\" to list5 at the index 5
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
        echo "L'un des arguments est une chaîne vide"
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
            echo "L'un des arguments est une chaîne vide"
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
        echo "La liste \"$1\" n'existe pas" >&2
        exit 1
    elif [[ -d "$1" ]]; then
        echo "La liste \"$1\" est actuellement un dossier" >&2
        exit 1
    fi
}
# la fonction checkArguments permet de savoir si l'utilisateur a passée au moins un argument
function checkArguments() {
    if [[ "$#" -eq 0 ]]; then
        echo "Vous devez entrer au moins un argument" >&2
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
        if [[ "$index" -eq 0 ]]; then
            echo "L'indice : \"$index\" doit être positive et plus grand que 0"
            exit 1
        fi
    done
}
# la fonction checkIndexType permet de savoir si l'un des arguments est une chaîne de caractères
function checkIndexType() {
    local regex='^[0-9]+$'
    for index in "$@"; do
        if ! [[ "$index" =~ $regex ]]; then
            echo "L'indice : \"$index\" est une chaîne de caractères et non pas un entier"
            exit 1
        fi
    done
}

####  MAIN ####
#--------------------------------------------------
# dès que l'utilisateur tape une commande la premiére fonction qui s'execute est selectOption
selectOption "$@"
#--------------------------------------------------
# chaque fonction qui se termine par Handling a pour but de gérer les erreurs
