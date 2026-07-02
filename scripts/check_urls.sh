#!/usr/bin/env bash
# __my_script__
#
# check_urls.sh — Vérifie qu'une liste d'URLs répond bien (HTTP 200) via curl-impersonate.
#
# Usage :
#   ./check_urls.sh <fichier_urls> [options]
#
# Options :
#   -j N      Parallélisme global (défaut : 10)
#   -p N      Parallélisme max par domaine (défaut : 2)
#   -t N      Timeout par requête en secondes (défaut : 10)
#   -b BIN    Binaire curl-impersonate à utiliser (défaut : curl_chrome116, fallback curl)
#   -a        Affiche aussi les URLs OK dans le rapport
#   -h        Aide
#
# Le fichier d'entrée : une URL par ligne. Lignes vides et commentaires (#) ignorés.
#
set -uo pipefail

# ----------------------------------------------------------------------------
# Valeurs par défaut
# ----------------------------------------------------------------------------
GLOBAL_PAR=10
DOMAIN_PAR=2
TIMEOUT=10
CURL_BIN="curl_chrome116"
SHOW_OK=0

# ----------------------------------------------------------------------------
# Couleurs (désactivées si pas un terminal)
# ----------------------------------------------------------------------------
if [[ -t 1 ]]; then
    C_RED=$'\033[31m'; C_GRN=$'\033[32m'; C_YEL=$'\033[33m'
    C_CYN=$'\033[36m'; C_BLD=$'\033[1m'; C_RST=$'\033[0m'
else
    C_RED=""; C_GRN=""; C_YEL=""; C_CYN=""; C_BLD=""; C_RST=""
fi

usage() {
    sed -n '2,20p' "$0" | sed 's/^# \{0,1\}//'
    exit "${1:-0}"
}

# ----------------------------------------------------------------------------
# Parsing des options
# ----------------------------------------------------------------------------
while getopts ":j:p:t:b:ah" opt; do
    case "$opt" in
        j) GLOBAL_PAR="$OPTARG" ;;
        p) DOMAIN_PAR="$OPTARG" ;;
        t) TIMEOUT="$OPTARG" ;;
        b) CURL_BIN="$OPTARG" ;;
        a) SHOW_OK=1 ;;
        h) usage 0 ;;
        :) echo "Option -$OPTARG requiert un argument." >&2; usage 1 ;;
        \?) echo "Option inconnue : -$OPTARG" >&2; usage 1 ;;
    esac
done
shift $((OPTIND - 1))

INPUT="${1:-}"
[[ -z "$INPUT" ]] && { echo "Erreur : fichier d'URLs manquant." >&2; usage 1; }
[[ -r "$INPUT" ]] || { echo "Erreur : fichier illisible : $INPUT" >&2; exit 1; }

# ----------------------------------------------------------------------------
# Détection du binaire curl
# ----------------------------------------------------------------------------
if ! command -v "$CURL_BIN" >/dev/null 2>&1; then
    echo "${C_YEL}Avertissement :${C_RST} '$CURL_BIN' introuvable, repli sur 'curl' classique." >&2
    echo "  (curl-impersonate est recommandé pour éviter les protections anti-bot)" >&2
    CURL_BIN="curl"
    command -v curl >/dev/null 2>&1 || { echo "Erreur : aucun curl disponible." >&2; exit 1; }
fi

# ----------------------------------------------------------------------------
# Dossier temporaire
# ----------------------------------------------------------------------------
TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' EXIT
RESULTS="$TMPDIR/results"   # lignes : domaine<TAB>url<TAB>code<TAB>temps
: > "$RESULTS"

# Sémaphore par domaine : un sous-dossier de fichiers-jetons
DOM_DIR="$TMPDIR/domains"
mkdir -p "$DOM_DIR"

# ----------------------------------------------------------------------------
# Fonctions
# ----------------------------------------------------------------------------

# Extrait le domaine (host) d'une URL.
domain_of() {
    local url="$1"
    # retire le schéma, le path, les credentials et le port
    url="${url#*://}"
    url="${url%%/*}"
    url="${url##*@}"
    url="${url%%:*}"
    printf '%s' "${url,,}"   # minuscule
}

# Verrou par domaine : limite DOMAIN_PAR requêtes concurrentes par host.
acquire_domain() {
    local dom="$1" slot
    local d="$DOM_DIR/$dom"
    mkdir -p "$d"
    while true; do
        for ((slot=0; slot<DOMAIN_PAR; slot++)); do
            if ( set -o noclobber; : > "$d/$slot" ) 2>/dev/null; then
                printf '%s' "$d/$slot"
                return 0
            fi
        done
        sleep 0.05
    done
}
release_domain() { rm -f "$1"; }

# Vérifie une URL et écrit le résultat.
check_url() {
    local url="$1"
    local dom; dom="$(domain_of "$url")"

    local lock; lock="$(acquire_domain "$dom")"

    local out code time_total
    out="$("$CURL_BIN" -s -o /dev/null \
            -L --max-redirs 5 \
            --connect-timeout "$TIMEOUT" --max-time $((TIMEOUT * 2)) \
            -w '%{http_code} %{time_total}' \
            "$url" 2>/dev/null)"
    local curl_rc=$?

    release_domain "$lock"

    code="${out%% *}"
    time_total="${out##* }"
    # curl renvoie "000" quand aucune réponse HTTP n'est obtenue
    [[ -z "$code" || ! "$code" =~ ^[0-9]+$ ]] && code=0
    [[ "$code" == "000" ]] && code=0

    # Si pas de code HTTP exploitable et curl en erreur, on encode l'erreur curl en négatif.
    if [[ "$code" == "0" && $curl_rc -ne 0 ]]; then
        code="-$curl_rc"
        time_total="0"
    fi

    printf '%s\t%s\t%s\t%s\n' "$dom" "$url" "$code" "$time_total" >> "$RESULTS"
}
export -f check_url domain_of acquire_domain release_domain
export CURL_BIN TIMEOUT DOMAIN_PAR DOM_DIR RESULTS

# ----------------------------------------------------------------------------
# Lecture des URLs
# ----------------------------------------------------------------------------
mapfile -t URLS < <(grep -vE '^\s*(#|$)' "$INPUT" | sed 's/[[:space:]]*$//')
TOTAL="${#URLS[@]}"
[[ "$TOTAL" -eq 0 ]] && { echo "Aucune URL à vérifier."; exit 0; }

echo "${C_BLD}Vérification de $TOTAL URL(s)${C_RST} — parallélisme global=$GLOBAL_PAR, par domaine=$DOMAIN_PAR, curl='$CURL_BIN'"
echo

# ----------------------------------------------------------------------------
# Exécution parallèle (10 par 10 globalement)
# ----------------------------------------------------------------------------
printf '%s\n' "${URLS[@]}" | xargs -d '\n' -P "$GLOBAL_PAR" -I {} bash -c 'check_url "$@"' _ {}

# ----------------------------------------------------------------------------
# Traduction des codes (HTTP + erreurs curl en négatif)
# ----------------------------------------------------------------------------
explain() {
    case "$1" in
        # --- 2xx / 3xx ---
        200) echo "OK" ;;
        201) echo "Créé" ;;
        202) echo "Accepté — traitement asynchrone (souvent un challenge anti-bot, contenu non garanti)" ;;
        203) echo "OK, info transformée par un proxy" ;;
        204) echo "OK, aucun contenu" ;;
        205) echo "OK, réinitialiser la vue" ;;
        206) echo "Contenu partiel (requête Range)" ;;
        226) echo "OK, IM Used" ;;
        300) echo "Choix multiples" ;;
        301) echo "Redirection permanente" ;;
        302|303|307|308) echo "Redirection" ;;
        304) echo "Non modifié (cache)" ;;
        # --- 4xx ---
        400) echo "Requête invalide" ;;
        401) echo "Authentification requise" ;;
        403) echo "Accès interdit — probable blocage anti-bot / WAF / géo-restriction" ;;
        404) echo "Page introuvable — URL morte ou déplacée" ;;
        405) echo "Méthode non autorisée (GET refusé ?)" ;;
        406) echo "Non acceptable — en-têtes/UA refusés (anti-bot ?)" ;;
        408) echo "Délai d'attente côté serveur" ;;
        410) echo "Ressource supprimée définitivement" ;;
        418) echo "I'm a teapot — souvent renvoyé par un anti-bot" ;;
        429) echo "Trop de requêtes — rate-limiting, ralentir / réduire -p" ;;
        451) echo "Indisponible pour raisons légales" ;;
        # --- 5xx ---
        500) echo "Erreur interne du serveur" ;;
        502) echo "Bad Gateway — proxy/serveur amont en échec" ;;
        503) echo "Service indisponible — surcharge, maintenance ou anti-bot" ;;
        504) echo "Gateway Timeout — serveur amont trop lent" ;;
        520|521|522|523|524|525|526) echo "Erreur Cloudflare (origine injoignable / TLS / timeout)" ;;
        # --- Erreurs curl (négatif) ---
        -6)  echo "DNS : hôte introuvable (domaine inexistant ?)" ;;
        -7)  echo "Connexion refusée / impossible (port fermé, serveur down)" ;;
        -28) echo "Timeout curl — pas de réponse dans le délai imparti" ;;
        -35) echo "Erreur de handshake TLS/SSL" ;;
        -47) echo "Trop de redirections" ;;
        -51) echo "Certificat TLS du serveur invalide" ;;
        -52) echo "Réponse vide du serveur" ;;
        -56) echo "Échec de réception des données (connexion coupée)" ;;
        -60) echo "Certificat TLS non vérifiable (CA inconnue / expiré)" ;;
        0)   echo "Aucune réponse HTTP (erreur réseau indéterminée)" ;;
        *)
            if [[ "$1" == -* ]]; then
                echo "Erreur curl (code ${1#-})"
            else
                echo "Code HTTP non répertorié"
            fi
            ;;
    esac
}

# Pour un contrôle de disponibilité, tout code 2xx ou 3xx = le site répond et l'URL existe.
# (4xx/5xx et erreurs curl restent des échecs.)
is_ok() { [[ "$1" =~ ^[23][0-9][0-9]$ ]]; }

# ----------------------------------------------------------------------------
# Rapport
# ----------------------------------------------------------------------------
ok_count=0; ko_count=0
ko_lines=""; ok_lines=""

while IFS=$'\t' read -r dom url code time; do
    reason="$(explain "$code")"
    # affichage du code : HTTP tel quel, ou "curl:N" si erreur curl, ou — si aucune réponse
    if [[ "$code" == -* ]]; then
        disp_code="curl:${code#-}"
    elif [[ "$code" == "0" ]]; then
        disp_code="—"
    else
        disp_code="$code"
    fi

    if is_ok "$code"; then
        ok_count=$((ok_count+1))
        ok_lines+="$(printf '%s\t%s\t%ss\t%s' "$disp_code" "$url" "$time" "$reason")"$'\n'
    else
        ko_count=$((ko_count+1))
        ko_lines+="$(printf '%s\t%s\t%ss\t%s' "$disp_code" "$url" "$time" "$reason")"$'\n'
    fi
done < "$RESULTS"

print_table() {
    # $1 = lignes TSV (code, url, temps, cause). Alignement en colonnes sans dépendance externe.
    {
        printf 'CODE\tURL\tTEMPS\tCAUSE PROBABLE\n'
        printf '%s' "$1"
    } | awk -F'\t' '
        { for (i=1;i<=NF;i++){ c[NR,i]=$i; if(length($i)>w[i]) w[i]=length($i) }; nf=NF; if(NF>maxf)maxf=NF }
        END {
            for (r=1;r<=NR;r++){
                line=""
                for (i=1;i<=maxf;i++){
                    cell=c[r,i]
                    if (i<maxf) line=line sprintf("%-*s  ", w[i], cell)
                    else        line=line cell
                }
                print line
            }
        }'
}

echo "${C_BLD}===== RAPPORT =====${C_RST}"
echo

if [[ "$ko_count" -gt 0 ]]; then
    echo "${C_RED}${C_BLD}URLs en échec ($ko_count) :${C_RST}"
    print_table "$ko_lines" | sed "1s/.*/${C_YEL}&${C_RST}/"
    echo
else
    echo "${C_GRN}Toutes les URLs ont répondu correctement.${C_RST}"
    echo
fi

if [[ "$SHOW_OK" -eq 1 && "$ok_count" -gt 0 ]]; then
    echo "${C_GRN}${C_BLD}URLs OK ($ok_count) :${C_RST}"
    print_table "$ok_lines" | sed "1s/.*/${C_CYN}&${C_RST}/"
    echo
fi

echo "${C_BLD}Total :${C_RST} $TOTAL — ${C_GRN}OK : $ok_count${C_RST} — ${C_RED}KO : $ko_count${C_RST}"

# Code de sortie : 0 si tout OK, 1 sinon (pratique pour la CI / cron).
[[ "$ko_count" -eq 0 ]]
