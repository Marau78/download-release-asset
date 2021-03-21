
if [[ -z $github_token ]]
then
  github_token=${GITHUB_TOKEN}
fi

if [[ -z $repo ]]
then
  repo=${GITHUB_REPOSITORY}
fi


url_api="https://api.github.com/repos/$repo/releases/tags/${release_name}"

if [[ -z $asset_name ]]
then
echo "in the null"
   artifact_names=($(curl -H "Authorization: token $github_token" "$url_api" | jq '.assets[]  | .name' | sed 's/\"//g'))
   urls_art=($(curl -H "Authorization: token $github_token" "$url_api" | jq '.assets[]  | .url' | sed 's/\"//g'))
 else
   artifact_names=$asset_name
   urls_art=$(curl -H "Authorization: token $github_token" "$url_api" | jq ".assets[] | select(.name==\"$asset_name\") | .url" | sed 's/\"//g')
fi

if [[ -z $dest_path ]]
then
    dest_path="./"
fi

mkdir -p $dest_path

cd $dest_path
len=${#urls_art[@]}
for (( i=0; i< $len;i++ ));
do
    # download the artifacts
    curl -vLJO -H 'Accept: application/octet-stream' -H "Authorization: token $github_token" ${urls_art[$i]}

    [[ ${artifact_names[$i]} == *".zip" ]] && unzip ${artifact_names[$i]}

done
ls
