require_relative "../lib/playlist"
require_relative "../lib/player"

# This adds a single track to the playlist and plays it on repeat for 15 seconds.

player = Mozart::Player.instance
player.playlist << "file://#{File.expand_path("#{File.dirname(__FILE__)}/dlanod.ogg")}"
player.play

sleep 15
