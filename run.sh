#! /bin/bash
set -x 
set -e

if [ -f .env ]; then
  export $(echo $(cat .env | sed 's/#.*//g'| xargs) | envsubst)
fi

echo $BACKUP_CONTENT_FOLDER
echo $GHOST_CONTENT_FOLDER
echo $BLOG_NAME
echo $GHOST_URL
#check if the backup directory exists
if [ -d "$BACKUP_CONTENT_FOLDER" ];
then
    rm -r $BACKUP_CONTENT_FOLDER
    cp -r $GHOST_CONTENT_FOLDER $BACKUP_CONTENT_FOLDER
else
    cp -r $GHOST_CONTENT_FOLDER $BACKUP_CONTENT_FOLDER

fi

docker stop $BLOG_NAME || true
docker rm $BLOG_NAME || true

# Send a request to the API and save the response
response=$(curl -s $API_ENDPOINT)

# Extract the version number of the latest Ghost image from the response
latest_version=$(echo $response | jq -r '."results"[1]."name"')

# Print the latest version number
echo "The latest version of Ghost is: $latest_version"

docker run -d \
  --name $BLOG_NAME \
  -v $GHOST_CONTENT_FOLDER:/var/lib/ghost/content \
  -p 3010:2368 \
  -e url=$GHOST_URL \
  -e database__client=sqlite3 \
  -e database__connection__filename="content/data/ghost.db" \
  -e database__useNullAsDefault=true \
  -e database__debug=false \
  --restart=unless-stopped \
  ghost:$latest_version-alpine
