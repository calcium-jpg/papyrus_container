#!/bin/sh

COMMAND="java -Xmx$MEMORY -jar ./server.jar --nogui"

if [ ! -f "./eula.txt" ]; then
  printf "eula=$EULA" > ./eula.txt
fi

if [ ! -f "./server.jar" ]; then

  if [ "$LOADER" == "PAPER" ]; then
    BUILDS_RESPONSE=$(curl -s -H "User-Agent: $USER_AGENT" https://fill.papermc.io/v3/projects/paper/versions/${MINECRAFT_VERSION}/builds)

    # Check if the API returned an error
    if echo "$BUILDS_RESPONSE" | jq -e '.ok == false' > /dev/null 2>&1; then
      ERROR_MSG=$(echo "$BUILDS_RESPONSE" | jq -r '.message // "Unknown error"')
      echo "Error: $ERROR_MSG"
      exit 1
    fi

    # Try to get a stable build URL for the requested version
    PAPERMC_URL=$(echo "$BUILDS_RESPONSE" | jq -r 'first(.[] | select(.channel == "STABLE") | .downloads."server:default".url) // "null"')

    # If no stable build for requested version, find the latest version with a stable build
    if [ "$PAPERMC_URL" == "null" ]; then
      echo "No stable build for version $MINECRAFT_VERSION"
      exit 1
    fi

    curl -o server.jar $PAPERMC_URL
    echo "Download completed (version: $MINECRAFT_VERSION (paper))"
  fi

  if [ "$LOADER" == "FABRIC" ]; then
    LOADER_BUILDS_RESPONSE=$(curl -s -H "User-Agent: $USER_AGENT" https://meta.fabricmc.net/v2/versions/loader/${MINECRAFT_VERSION})

    # Check if the API returned an error
    if echo "$LOADER_BUILDS_RESPONSE" | jq -e '.ok == false' > /dev/null 2>&1; then
      ERROR_MSG=$(echo "$LOADER_BUILDS_RESPONSE" | jq -r '.message // "Unknown error"')
      echo "Error: $ERROR_MSG"
      exit 1
    fi

    # Try to get a stable build URL for the requested version
    LOADER_VERSION=$(echo "$LOADER_BUILDS_RESPONSE" | jq -r 'first(.[] | select(.loader.stable == true) | .loader.version) // "null"')

    # If no stable build for requested version, find the latest version with a stable build
    if [ "$LOADER_VERSION" == "null" ]; then
      echo "No stable build for version $MINECRAFT_VERSION"
      exit 1
    fi

    INSTALLER_BUILDS_RESPONSE=$(curl -s -H "User-Agent: $USER_AGENT" https://meta.fabricmc.net/v2/versions/installer)

    if echo "$INSTALLER_BUILDS_RESPONSE" | jq -e '.ok == false' > /dev/null 2>&1; then
      ERROR_MSG=$(echo "$INSTALLER_BUILDS_RESPONSE" | jq -r '.message // "Unknown error"')
      echo "Error: $ERROR_MSG"
      exit 1
    fi

    INSTALLER_VERSION=$(echo "$INSTALLER_BUILDS_RESPONSE" | jq -r 'first(.[] | select(.stable == true) | .version) // "null"')

    if [ "$INSTALLER_VERSION" == "null" ]; then
      echo "No stable installer for fabric"
      exit 1
    fi

    curl -o server.jar https://meta.fabricmc.net/v2/versions/loader/$MINECRAFT_VERSION/$LOADER_VERSION/$INSTALLER_VERSION/server/jar
    echo "Download completed (version: $MINECRAFT_VERSION (fabric))"
  fi

  #if [ "$LOADER" == "NEOFORGE" ]; then
  #  curl -o installer.jar https://maven.neoforged.net/releases/net/neoforged/neoforge/$MINECRAFT_VERSION/neoforge-$MINECRAFT_VERSION-installer.jar
  #  java -jar ./installer.jar --installServer
  #  COMMAND="java -Xmx$MEMORY @libraries/net/neoforged/neoforge/$MINECRAFT_VERSION/unix_args.txt nogui"
  #  rm ./installer.jar
  #  echo "Download & install completed (version: $MINECRAFT_VERSION (NEOFORGE))"
  #fi

  #if [ "$LOADER" == "FORGE" ]; then
  #  curl -o installer.jar https://maven.minecraftforge.net/net/minecraftforge/forge/$MINECRAFT_VERSION/forge-$MINECRAFT_VERSION-installer.jar
  #  java -jar ./installer.jar --installServer
  #  COMMAND="java -Xmx$MEMORY @libraries/net/minecraftforge/forge/$MINECRAFT_VERSION/unix_args.txt nogui"
  #  rm ./installer.jar
  #  echo "Download & install completed (version: $MINECRAFT_VERSION (FORGE))"
  #fi
fi

exec $COMMAND
