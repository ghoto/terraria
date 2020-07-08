#!/bin/sh

echo "\nBootstrap:\nworld_file_name=/worlds/$WORLD_FILENAME\nlogpath=$LOGPATH\n"
echo "Copying plugins..."
cp -Rfv /plugins/* ./ServerPlugins

WORLD_PATH="/worlds/$WORLD_FILENAME"

if [ -z "$WORLD_FILENAME" ]; then
  echo "No world file specified in environment WORLD_FILENAME."
  if [ -z "$@" ]; then 
    echo "Running server setup..."
  else
    echo "Running server with command flags: $@"
  fi
  mono --server --gc=sgen -O=all TerrariaServer.exe -configpath "/worlds" -logpath "$LOGPATH" "$@" 
else
  echo "Environment WORLD_FILENAME specified"
  if [ -f "$WORLD_PATH" ]; then
    echo "Loading to world $WORLD_FILENAME..."
    mono --server --gc=sgen -O=all TerrariaServer.exe -configpath "/worlds" -logpath "$LOGPATH" -world "$WORLD_PATH" "$@" 
  else
    echo "Unable to locate $WORLD_PATH.\nPlease make sure your world file is volumed into docker: -v <path_to_world_file>:/worlds"
    exit 1
  fi
fi
