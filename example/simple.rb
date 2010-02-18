require_relative "../lib/playlist"
require_relative "../lib/player"

# This adds a single track to the playlist and plays it on repeat for 15 seconds.

player = Mozart::Player.instance
playlist = Mozart::Playlist.new("example")
playlist << "file://#{File.expand_path("#{File.dirname(__FILE__)}/dlanod.ogg")}"
player.playlist = playlist

sleep 15
