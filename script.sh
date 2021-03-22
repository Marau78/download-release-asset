
if [[ -z "$repo" ]]
then
  echo 'repo not set'
  repo=${GITHUB_REPOSITORY}
fi


url_api="https://api.github.com/repos/$repo/releases/tags/${release_name}"
echo $url_api

if [[ -z "$asset_name" ]]
then
   echo "asset not set"
   if [[ -z "$token" ]]
   then
      echo "token not set"
      artifact_names=($(curl $url_api | jq '.assets[]  | .name' | sed 's/\"//g'))
      urls_art=($(curl $url_api | jq '.assets[]  | .url' | sed 's/\"//g'))
   else
      artifact_names=($(curl -H "Authorization: token $token" $url_api | jq '.assets[]  | .name' | sed 's/\"//g'))
      urls_art=($(curl -H "Authorization: token $token" $url_api | jq '.assets[]  | .url' | sed 's/\"//g'))
   fi
else
   echo "asset name $asset_name"
   artifact_names=$asset_name
   if [[ -z "$token" ]]
   then
   echo "token not set"
      urls_art=$(curl $url_api | jq ".assets[] | select(.name==\"$asset_name\") | .url" | sed 's/\"//g')
   else
      urls_art=$(curl -H "Authorization: token $token" $url_api | jq ".assets[] | select(.name==\"$asset_name\") | .url" | sed 's/\"//g')
   fi
fi

if [[ -z "$dest_path" ]]
then
    dest_path="./"
fi

mkdir -p $dest_path

cd $dest_path
len=${#urls_art[@]}
for (( i=0; i< $len;i++ ));
do
    # download the artifacts
    if [[ -z "$token" ]]
    then
      curl -vLJO -H 'Accept: application/octet-stream' ${urls_art[$i]}
    else
      curl -vLJO -H 'Accept: application/octet-stream' -H "Authorization: token $token" ${urls_art[$i]}
    fi
    [[ ${artifact_names[$i]} == *".zip" ]] && unzip ${artifact_names[$i]}

done
ls
