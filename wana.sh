#!/bin/sh

cmd=""
filter_a=""
filter_b=""
filter_ip=""
filter_uri=""
log_files=""

while [ $# -gt 0 ]
do 
    if [ "$1" = "-a" ]; then
        filter_a=$2
        shift 2
    elif [ "$1" = "-b" ]; then
        filter_b=$2
        shift 2
    elif [ "$1" = "-ip" ]; then
        filter_ip=$2
        shift 2
    elif [ "$1" = "-uri" ]; then
        filter_uri=$2
        shift 2
    elif [ "$1" = "list-ip" ] || [ "$1" = "list-hosts" ] || [ "$1" = "list-uri" ] || [ "$1" = "hist-ip" ] || [ "$1" = "hist-load" ]; then
        cmd=$1
        shift 1
    elif echo "$1" | grep -q "^-"; then
        echo "Error: unknown option" >&2
        exit 1
    else
        log_files="$log_files $1"
        shift
    fi
done

{
    if [ -z "$log_files" ]; then
        cat -
    else
        for f in $log_files
        do
            case "$f" in
                *.gz) gunzip -c "$f" ;;
                *)    cat "$f" ;;
            esac
        done
    fi
} |
gawk -v a="$filter_a" -v b="$filter_b" -v ip="$filter_ip" -v uri="$filter_uri" '
BEGIN{
    m["Jan"]="01"; m["Feb"]="02"; m["Mar"]="03"; m["Apr"]="04";
    m["May"]="05"; m["Jun"]="06"; m["Jul"]="07"; m["Aug"]="08";
    m["Sep"]="09"; m["Oct"]="10"; m["Nov"]="11"; m["Dec"]="12";
    if(a != ""){
        gsub(/[-:]/," ",a)
        time_a=mktime(a)
    }
    if(b != ""){
        gsub(/[-:]/," ",b)
        time_b=mktime(b)
    }
}
{
    raw_date=substr($4,2)
    split(raw_date, c, /[\/:]/)
    d=c[3] " " m[c[2]] " " c[1] " " c[4] " " c[5] " " c[6]
    raw_time=mktime(d)
    if(a != "" && raw_time < time_a) next
    if(b != "" && raw_time > time_b) next
    if(ip != "" && $1 != ip) next
    if(uri != "" && index($7, uri) == 0) next
    print $0
}
' 2>/dev/null | 
if [ "$cmd" = "list-ip" ]; then
    awk '{print $1}' | sort | uniq 
elif [ "$cmd" = "list-hosts" ]; then
    awk '{print $1}' | sort | uniq |
    while read -r ip; do
        res=$(host "$ip" 2>/dev/null)
        if echo "$res" | grep -q "not found"; then
            echo "$ip"
        else
            echo "$res" | awk '{sub(/\.$/, "", $NF); print $NF}'
        fi
    done
elif [ "$cmd" = "list-uri" ]; then 
    awk '{print $7}' | sort | uniq
elif [ "$cmd" = "hist-ip" ]; then 
    awk '{print $1}' | sort | uniq -c |
    awk '{printf "%s (%d): ", $2, $1; for (i = 0; i < $1; i++){printf "#"}; print ""}'
elif [ "$cmd" = "hist-load" ]; then 
    awk '
    BEGIN {
        m["Jan"]="01"; m["Feb"]="02"; m["Mar"]="03"; m["Apr"]="04";
        m["May"]="05"; m["Jun"]="06"; m["Jul"]="07"; m["Aug"]="08";
        m["Sep"]="09"; m["Oct"]="10"; m["Nov"]="11"; m["Dec"]="12";
    }
    {
        split(substr($4, 2), c, /[\/:]/)
        printf "%s-%s-%s %s:00\n", c[3], m[c[2]], c[1], c[4]
    }' |
    sort | uniq -c |
    awk '{printf "%s %s (%d): ", $2, $3, $1; for (i = 0; i < $1; i++){printf "#"}; print ""}'
else
    echo "Error: unknown command '$cmd'" >&2
    exit 1
fi