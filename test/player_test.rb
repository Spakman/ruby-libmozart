require "test/unit"
require_relative "../lib/player"

class PlayerTest < Test::Unit::TestCase

  def teardown
    Mozart::Player.quiesce
    sleep 0.2
  end

  def test_set_playlist_starts_playing
    playlist = Mozart::Playlist.new
    playlist << Struct.new(:url).new("file://#{File.expand_path(File.dirname(__FILE__))}/dlanod.ogg")
    Mozart::Player.instance.playlist = playlist
    sleep 0.5
    assert Mozart::Player.instance.playing?
  end

  def test_pause
    playlist = Mozart::Playlist.new
    playlist << Struct.new(:url).new("file://#{File.expand_path(File.dirname(__FILE__))}/dlanod.ogg")
    Mozart::Player.instance.playlist = playlist
    sleep 0.4
    assert Mozart::Player.instance.playing?
    Mozart::Player.instance.pause
    sleep 0.2
    assert Mozart::Player.instance.paused?
  end

  def test_play
    playlist = Mozart::Playlist.new
    playlist << Struct.new(:url).new("file://#{File.expand_path(File.dirname(__FILE__))}/dlanod.ogg")
    Mozart::Player.instance.playlist = playlist
    sleep 0.2
    Mozart::Player.instance.pause
    sleep 0.2
    Mozart::Player.instance.play
    sleep 0.2
    assert Mozart::Player.instance.playing?
  end
end
