# Papyrus Container

## Arguments
- JAVA_VERSION (default: 21), match with the required Java version for selected version of Minecraft

## Environment Variables
- EULA (default: false), set to true in order to agree to Minecraft's EULA (https://www.minecraft.net/en-us/eula)
- LOADER (default: PAPER), set to either "PAPER" or "FABRIC" in order to switch the downloaded loader
- MINECRAFT_VERSION (default: 1.21), set to the desired minecraft (or forge/neoforge) version
- MEMORY (default: 4G), set to the desired "-Xmx" value for the Java VM

## Ports
- Port exposed is 25565/tcp

## Example Command
```podman run -e LOADER="FABRIC" -e MINECRAFT_VERSION="1.21.11" -e EULA="true" -P -i localhost/minecraft:latest```
