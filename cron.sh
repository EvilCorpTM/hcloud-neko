now=$(date +'%s')

for row in $(hcloud server list -l "neko=1" -o "json" | jq -r '.[] | @base64'); do
        _jq() {
                echo ${row} | base64 --decode | jq -r ${1}
        }
        name=$(_jq '.name')
        expire=$(_jq '.labels.expire')
	#echo "$now -$expire"
	if [ $expire -le $now ]; then
		#echo "$name is expired| now its $now | expireDate is $expire"
		hcloud server delete $name > /dev/null
	fi
done
