#! /bin/bash

#check if the backup directory exists
DIR=path/to/ghost/content/folder-bk
if [ -d "$DIR" ];
then
    rm -r path/to/ghost/content/folder-bk
    cp -r path/to/ghost/content/folder path/to/ghost/content/folder-bk
else
    cp -r path/to/ghost/content/folder path/to/ghost/content/folder-bk

fi

docker stop blog-name
docker rm blog-name


# Set the API endpoint for the Ghost image
api_endpoint="https://registry.hub.docker.com/v2/repositories/library/ghost/tags"

# Send a request to the API and save the response
response=$(curl -s $api_endpoint)

# Extract the version number of the latest Ghost image from the response
latest_version=$(echo $response | jq -r '."results"[1]."name"')

# Print the latest version number
echo "The latest version of Ghost is: $latest_version"

docker run -d \
  --name blog-name \
  -v path/to/ghost/content/folder:/var/lib/ghost/content \
  -p 3010:2368 \
  -e url=https://example-blog.com \
  -e database__client=sqlite3 \
  -e database__connection__filename="content/data/ghost.db" \
  -e database__useNullAsDefault=true \
  -e database__debug=false \
  --restart=unless-stopped \
  ghost:$latest_version-alpine
