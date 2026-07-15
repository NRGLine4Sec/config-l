#!/usr/bin/env bash
# __my_script__
#
# doublons.sh - Detection de doublons par empreinte xxh128, avec :
#   * une section « repertoires au contenu recouvrant » en tete de rapport
#   * la liste des groupes de doublons, triee par espace disque croissant
#
# Le rapport part sur la sortie standard (redirigeable vers un fichier).
# La progression part sur la sortie d'erreur (reste visible au terminal).
#
# Usage :
#   ./doublons.sh [-s SEUIL] [-j PARALLELISME] [REPERTOIRE] > rapport.txt
#
# Options :
#   -s SEUIL         nombre minimum de fichiers identiques en commun pour
#                    signaler une paire de repertoires (defaut : 5)
#   -j PARALLELISME  nombre de jobs paralleles, entier ou pourcentage des
#                    coeurs (defaut : 100%)
#   -h               affiche cette aide
#
# Tous les noms de fichiers sont manipules en NUL-termine : espaces multiples,
# retours a la ligne, alphabets non latins et emoji sont supportes.

set -euo pipefail

SEUIL=5
JOBS='100%'

while getopts ':s:j:h' opt; do
    case "$opt" in
        s) SEUIL=$OPTARG ;;
        j) JOBS=$OPTARG ;;
        h) sed -n '3,22p' "$0"; exit 0 ;;
        :) printf 'Erreur : option -%s : argument manquant.\n' "$OPTARG" >&2; exit 2 ;;
        *) printf 'Erreur : option inconnue -%s.\n' "$OPTARG" >&2; exit 2 ;;
    esac
done
shift $((OPTIND - 1))

RACINE="${1:-.}"

# ---------------------------------------------------------------------------
# Verifications prealables
# ---------------------------------------------------------------------------
for outil in xxh128sum find awk cut tr sort uniq xargs nproc; do
    if ! command -v "$outil" >/dev/null 2>&1; then
        printf 'Erreur : « %s » est introuvable dans le PATH.\n' "$outil" >&2
        exit 1
    fi
done

if [[ ! -d "$RACINE" ]]; then
    printf 'Erreur : « %s » n est pas un répertoire.\n' "$RACINE" >&2
    exit 1
fi

if ! [[ "$SEUIL" =~ ^[0-9]+$ ]] || (( SEUIL < 1 )); then
    printf 'Erreur : le seuil doit être un entier positif.\n' >&2
    exit 2
fi

# Normalisation du parallelisme : xargs -P veut un entier.
if [[ "$JOBS" == *% ]]; then
    pct=${JOBS%\%}
    if ! [[ "$pct" =~ ^[0-9]+$ ]]; then
        printf 'Erreur : parallélisme invalide : %s\n' "$JOBS" >&2
        exit 2
    fi
    NPROC=$(( $(nproc) * pct / 100 ))
    (( NPROC < 1 )) && NPROC=1
else
    NPROC=$JOBS
fi

if ! [[ "$NPROC" =~ ^[0-9]+$ ]] || (( NPROC < 1 )); then
    printf 'Erreur : parallélisme invalide : %s\n' "$JOBS" >&2
    exit 2
fi

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT INT TERM

# ---------------------------------------------------------------------------
# Fonctions utilitaires
# ---------------------------------------------------------------------------

# Barre de progression sur stderr.
barre() {
    local courant=$1 total=$2 largeur=40 pct rempli vide i
    (( total == 0 )) && return
    pct=$(( courant * 100 / total ))
    rempli=$(( courant * largeur / total ))
    vide=$(( largeur - rempli ))
    printf '\r  [' >&2
    for (( i = 0; i < rempli; i++ )); do printf '#' >&2; done
    for (( i = 0; i < vide;   i++ )); do printf '.' >&2; done
    printf '] %3d%%  %d/%d' "$pct" "$courant" "$total" >&2
}

# Calcul d empreintes pour un lot de fichiers.
#
# On ne parse jamais la sortie brute de xxh128sum : il echappe les noms
# contenant \n ou \\ en prefixant la ligne d un antislash. On ne lui prend
# donc que les 32 premiers caracteres (l empreinte), et on reemet le chemin
# depuis notre propre variable de boucle, jamais depuis sa sortie.
hacher() {
    local f h
    for f in "$@"; do
        h=$(xxh128sum -- "$f") || continue
        printf '%s\t%s\0' "${h:0:32}" "$f"
    done
}
export -f hacher

# ---------------------------------------------------------------------------
# Etape 1 : inventaire (taille \t chemin, NUL-termine)
#
# find -printf '%s' emet la taille EXACTE en octets, en decimal, sans suffixe
# ni arrondi (contrairement a du -h, ls -lh ou stat --format avec unites).
# C est indispensable : le pre-filtrage de l etape 2 repose entierement sur
# une egalite stricte de taille. Une taille arrondie ferait passer pour
# identiques deux fichiers de tailles differentes, ce qui ne serait pas un
# faux positif final (le hash trancherait ensuite) mais annulerait le gain,
# et inversement un arrondi different pour deux fichiers de meme taille les
# ferait passer dans deux classes distinctes, ce qui produirait des faux
# NEGATIFS, donc des doublons manques. Aucun arrondi n est acceptable ici.
# ---------------------------------------------------------------------------
printf 'Inventaire des fichiers sous « %s »...\n' "$RACINE" >&2

find "$RACINE" -type f -printf '%s\t%p\0' > "$TMP/inventaire"

TOTAL=$(tr -cd '\0' < "$TMP/inventaire" | wc -c)

if (( TOTAL == 0 )); then
    printf 'Aucun fichier trouvé. Rien à faire.\n' >&2
    exit 0
fi

printf 'Fichiers inventoriés : %d\n\n' "$TOTAL" >&2

# ---------------------------------------------------------------------------
# Etape 2 : pre-filtrage par taille exacte
#
# RATIONNEL
# ---------
# Deux fichiers identiques ont necessairement la meme taille en octets. La
# contraposee est ce qui nous interesse : un fichier dont la taille est UNIQUE
# dans tout l arbre analyse ne peut, par construction, avoir aucun doublon.
# Il est donc inutile de lire son contenu pour le hacher.
#
# Ce n est PAS une heuristique et cela n introduit AUCUN risque de faux
# negatif : c est une implication logique stricte. La detection reste
# exclusivement fondee sur l empreinte xxh128 ; le filtre par taille ne fait
# qu ecarter en amont des candidats dont on sait avec certitude qu ils ne
# peuvent pas collisionner.
#
# OBJECTIF : GAIN D EFFICACITE
# ----------------------------
# Le cout dominant de ce script n est ni le fork, ni le tri, ni awk : c est la
# LECTURE INTEGRALE du contenu de chaque fichier, imposee par le hachage. Sur
# une arborescence de plusieurs centaines de milliers de fichiers, cela
# represente potentiellement des dizaines ou des centaines de gigaoctets lus
# depuis le stockage.
#
# Or l inventaire de l etape 1 nous a deja donne la taille de chaque fichier
# GRATUITEMENT : find l obtient par le stat() qu il fait de toute facon lors
# du parcours, sans jamais ouvrir ni lire les fichiers.
#
# On exploite donc une information deja payee pour eviter un cout tres eleve.
# Sur une arborescence reelle, la majorite des fichiers ont une taille unique
# et sont ecartes sans etre lus. Le volume d E/S effectivement lu s effondre,
# et le temps d execution avec lui. C est de tres loin l optimisation la plus
# rentable de ce script, bien avant toute consideration de parallelisme, de
# tmpfs ou de reduction du nombre de forks.
#
# MISE EN OEUVRE
# --------------
#   1. On extrait la colonne des tailles, on trie, et `uniq -d` ne conserve
#      que les tailles apparaissant AU MOINS DEUX FOIS.
#   2. On ne retient de l inventaire que les fichiers dont la taille figure
#      dans cet ensemble. Eux seuls seront haches.
#
# La comparaison des tailles se fait en CHAINE de caracteres, pas en valeur
# numerique : find emet des entiers decimaux canoniques (pas de zeros de tete,
# pas de notation exponentielle), donc l egalite de chaine est strictement
# equivalente a l egalite d octets, et l on evite toute conversion vers un
# type flottant. awk stocke ses nombres en double IEEE 754, qui represente
# certes exactement tout entier jusqu a 2^53 (9 Pio, donc largement au dela de
# toute taille de fichier reelle), mais rester en chaine supprime la question.
# ---------------------------------------------------------------------------
printf 'Pré-filtrage par taille exacte...\n' >&2

# Tailles apparaissant au moins deux fois dans l arbre.
tr '\0' '\n' < "$TMP/inventaire" \
  | cut -f1 \
  | sort \
  | uniq -d > "$TMP/tailles_partagees"

# Chemins des seuls fichiers dont la taille est partagee (NUL-termine).
# Le fichier des tailles est passe en argument positionnel (pas en getline) :
# lu avec RS=\0 il arrive en un seul enregistrement puisqu il ne contient
# aucun NUL, donc on le redecoupe nous-memes sur les sauts de ligne. Cela
# evite tout conflit entre le RS global (\0) et la lecture ligne par ligne.
awk -v RS='\0' -v ORS='\0' -v FS='\t' '
FNR == NR {
    nb = split($0, lignes, "\n")
    for (k = 1; k <= nb; k++) {
        if (lignes[k] != "") partagee[lignes[k]] = 1
    }
    next
}
$1 in partagee { print $2 }
' "$TMP/tailles_partagees" "$TMP/inventaire" > "$TMP/chemins"

CANDIDATS=$(tr -cd '\0' < "$TMP/chemins" | wc -c)
ECARTES=$(( TOTAL - CANDIDATS ))

printf 'Écartés (taille unique, aucun doublon possible) : %d\n' "$ECARTES" >&2
printf 'Candidats à hacher                             : %d\n' "$CANDIDATS" >&2
if (( TOTAL > 0 )); then
    printf 'Lectures évitées                               : %d%%\n\n' \
        $(( ECARTES * 100 / TOTAL )) >&2
fi

if (( CANDIDATS == 0 )); then
    printf 'Aucun doublon possible : toutes les tailles sont uniques.\n' >&2
    exit 0
fi

# ---------------------------------------------------------------------------
# Etape 3 : empreintes xxh128 des seuls candidats, en parallele
#
# xargs -0 -n50 -P N : un shell pour 50 fichiers, N shells en parallele.
# Chaque printf reste bien en dessous de PIPE_BUF (4096 o) et le fichier de
# sortie est ouvert en O_APPEND, donc les ecritures concurrentes ne
# s entrelacent pas.
#
# Le `_` est ici legitime : bash -c consomme son premier argument comme $0,
# les suivants peuplent "$@". C est ce que GNU parallel ne fait PAS, d ou son
# abandon au profit de xargs.
# ---------------------------------------------------------------------------
printf 'Calcul des empreintes xxh128 (%d job(s) en parallèle) :\n' "$NPROC" >&2

: > "$TMP/empreintes"

# Barre de progression en tache de fond : compte les NUL deja ecrits.
progression() {
    local fait
    while :; do
        fait=$(tr -cd '\0' < "$TMP/empreintes" 2>/dev/null | wc -c)
        (( fait > CANDIDATS )) && fait=$CANDIDATS
        barre "$fait" "$CANDIDATS"
        (( fait >= CANDIDATS )) && break
        sleep 1
    done
}

progression &
PID_BARRE=$!

xargs -0 -n50 -P "$NPROC" bash -c 'hacher "$@"' _ \
    < "$TMP/chemins" >> "$TMP/empreintes"

kill "$PID_BARRE" 2>/dev/null || true
wait "$PID_BARRE" 2>/dev/null || true

HACHES=$(tr -cd '\0' < "$TMP/empreintes" | wc -c)
barre "$HACHES" "$CANDIDATS"
printf '\n\n' >&2

if (( HACHES != CANDIDATS )); then
    printf 'Attention : %d empreintes calculées pour %d candidats.\n' \
        "$HACHES" "$CANDIDATS" >&2
    printf 'Des fichiers ont pu être supprimés ou sont illisibles pendant le parcours.\n\n' >&2
fi

printf 'Génération du rapport...\n\n' >&2

# ---------------------------------------------------------------------------
# Etape 4 : rapport sur la sortie standard
#
# NOTE : awk recoit l inventaire COMPLET (passe 1) et non le seul sous-ensemble
# des candidats. C est voulu : total_rep[] doit compter TOUS les fichiers de
# chaque repertoire, y compris ceux ecartes par le pre-filtrage, sans quoi les
# pourcentages de recouvrement de la section 1 seraient calcules sur une base
# tronquee et donc faux. Seule la passe 2 (empreintes) est restreinte aux
# candidats, ce qui est correct puisqu elle ne sert qu a former les groupes de
# doublons.
# ---------------------------------------------------------------------------
awk -v RS='\0' -v FS='\t' -v seuil="$SEUIL" -v racine="$RACINE" '

# --- Passe 1 : inventaire complet (taille \t chemin) ---
# Sert a deux choses : la table des tailles, et le comptage du nombre total de
# fichiers par repertoire (denominateur des pourcentages de recouvrement).
NR == FNR {
    taille[$2] = $1
    total_rep[repertoire($2)]++
    next
}

# --- Passe 2 : empreintes des candidats (hash \t chemin) ---
{
    h = $1
    f = $2

    n[h]++
    membre[h, n[h]] = f
}

END {
    # -----------------------------------------------------------------------
    # Comptage des empreintes partagees entre paires de repertoires.
    # Une meme empreinte ne compte qu une fois par paire, meme si un
    # repertoire en contient plusieurs exemplaires.
    # -----------------------------------------------------------------------
    for (h in n) {
        if (n[h] < 2) continue

        delete vus
        nb_rep = 0
        for (i = 1; i <= n[h]; i++) {
            d = repertoire(membre[h, i])
            if (!(d in vus)) {
                vus[d] = 1
                reps[++nb_rep] = d
            }
        }

        u = taille[membre[h, 1]] + 0

        for (i = 1; i <= nb_rep; i++) {
            for (j = i + 1; j <= nb_rep; j++) {
                a = reps[i]
                b = reps[j]
                cle = (a < b) ? (a SUBSEP b) : (b SUBSEP a)
                commun[cle]++
                octets[cle] += u
            }
        }
    }

    # -----------------------------------------------------------------------
    # Section 1 : repertoires au contenu recouvrant
    # -----------------------------------------------------------------------
    print "###################################################################"
    print "#  RÉPERTOIRES AU CONTENU RECOUVRANT"
    printf "#  Paires partageant au moins %d fichier(s) identique(s)\n", seuil
    printf "#  Racine analysée : %s\n", racine
    print "###################################################################"
    print ""

    nb_paires = 0
    for (cle in commun) {
        if (commun[cle] >= seuil) {
            cles[++nb_paires] = cle
        }
    }

    if (nb_paires == 0) {
        printf "Aucune paire de répertoires n atteint le seuil de %d fichiers communs.\n\n", seuil
    } else {
        # Tri decroissant sur le nombre de fichiers communs (tri par insertion).
        for (i = 2; i <= nb_paires; i++) {
            courant = cles[i]
            j = i - 1
            while (j >= 1 && commun[cles[j]] < commun[courant]) {
                cles[j + 1] = cles[j]
                j--
            }
            cles[j + 1] = courant
        }

        for (i = 1; i <= nb_paires; i++) {
            split(cles[i], p, SUBSEP)
            a = p[1]
            b = p[2]

            pa = (total_rep[a] > 0) ? (commun[cles[i]] * 100.0 / total_rep[a]) : 0
            pb = (total_rep[b] > 0) ? (commun[cles[i]] * 100.0 / total_rep[b]) : 0

            print "-------------------------------------------------------------------"
            printf "%d fichier(s) en commun   (%s partagés)\n",
                   commun[cles[i]], humain(octets[cles[i]])
            printf "  A : %s\n", a
            printf "      %d fichier(s) au total, soit %.0f%% en commun avec B\n",
                   total_rep[a], pa
            printf "  B : %s\n", b
            printf "      %d fichier(s) au total, soit %.0f%% en commun avec A\n",
                   total_rep[b], pb
            printf "  => %s\n", verdict(pa, pb)
            print ""
        }
    }

    # -----------------------------------------------------------------------
    # Section 2 : groupes de doublons, tries par espace occupe croissant
    # -----------------------------------------------------------------------
    print ""
    print "###################################################################"
    print "#  GROUPES DE DOUBLONS"
    print "#  Tri croissant sur l espace disque total occupé par le groupe"
    print "###################################################################"
    print ""

    nb_groupes = 0
    for (h in n) {
        if (n[h] < 2) continue
        occupe[h] = (taille[membre[h, 1]] + 0) * n[h]
        ordre[++nb_groupes] = h
    }

    if (nb_groupes == 0) {
        print "Aucun doublon détecté."
        exit 0
    }

    for (i = 2; i <= nb_groupes; i++) {
        courant = ordre[i]
        j = i - 1
        while (j >= 1 && occupe[ordre[j]] > occupe[courant]) {
            ordre[j + 1] = ordre[j]
            j--
        }
        ordre[j + 1] = courant
    }

    total_fichiers = 0
    total_recuperable = 0

    for (i = 1; i <= nb_groupes; i++) {
        h = ordre[i]
        u = taille[membre[h, 1]] + 0
        recuperable = u * (n[h] - 1)

        total_fichiers += n[h]
        total_recuperable += recuperable

        print "==================================================================="
        printf "HASH        : %s\n", h
        printf "EXEMPLAIRES : %d\n", n[h]
        printf "UNITAIRE    : %s\n", humain(u)
        printf "OCCUPÉ      : %s\n", humain(occupe[h])
        printf "RÉCUPÉRABLE : %s\n", humain(recuperable)
        print  "FICHIERS    :"
        for (k = 1; k <= n[h]; k++) {
            printf "  %s\n", membre[h, k]
        }
        print ""
    }

    print "==================================================================="
    print "BILAN"
    printf "  Groupes de doublons  : %d\n", nb_groupes
    printf "  Fichiers concernés   : %d\n", total_fichiers
    printf "  Espace récupérable   : %s\n", humain(total_recuperable)
}

# ---------------------------------------------------------------------------
# Fonctions awk
# ---------------------------------------------------------------------------

# Repertoire parent d un chemin, sans fork vers dirname.
function repertoire(chemin,   d) {
    d = chemin
    if (sub(/\/[^\/]*$/, "", d)) {
        return (d == "") ? "/" : d
    }
    return "."
}

# Taille lisible par un humain (base 1024).
function humain(o,   unites, i) {
    split("o Kio Mio Gio Tio Pio", unites, " ")
    i = 1
    while (o >= 1024 && i < 6) {
        o /= 1024
        i++
    }

    if (i == 1) return sprintf("%d %s", o, unites[i])
    	return sprintf("%.1f %s", o, unites[i])
}

# Interpretation du recouvrement entre deux repertoires.
function verdict(pa, pb) {
    if (pa >= 99 && pb >= 99) return "Contenus quasi identiques."
    if (pa >= 99)             return "A semble entièrement contenu dans B."
    if (pb >= 99)             return "B semble entièrement contenu dans A."
    if (pa >= 50 || pb >= 50) return "Recouvrement partiel important."
    return "Recouvrement partiel."
}

' "$TMP/inventaire" "$TMP/empreintes"

printf 'Terminé.\n' >&2