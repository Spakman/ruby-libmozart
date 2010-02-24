require "test/unit"
require_relative "../lib/playlist"

class PlaylistTest < Test::Unit::TestCase

  def teardown
    Mozart::Player.quiesce
  end

  def test_create_without_uris
    @playlist = Mozart::Playlist.new
    assert_equal 0, @playlist.size
    refute @playlist.shuffled?
  end

  def test_shuffle_playlist
    playlist = Mozart::Playlist.new
    playlist << Struct.new(:url).new("file://#{File.expand_path(File.dirname(__FILE__))}/dlanod.ogg")
    playlist << Struct.new(:url).new("file://more_music")
    Mozart::Player.instance.playlist = playlist
    playlist.toggle_shuffled_state
    assert playlist.shuffled?
  end

  def test_unshuffle_playlist
    playlist = Mozart::Playlist.new
    playlist << Struct.new(:url).new("file://#{File.expand_path(File.dirname(__FILE__))}/dlanod.ogg")
    playlist << Struct.new(:url).new("file://more_music")
    Mozart::Player.instance.playlist = playlist
    playlist.toggle_shuffled_state
    playlist.toggle_shuffled_state
    refute playlist.shuffled?
  end

  def test_active?
    playlist = Mozart::Playlist.new
    other_playlist = Mozart::Playlist.new
    playlist << Struct.new(:url).new("track1") <<  Struct.new(:url).new("track2")
    Mozart::Player.instance.playlist = playlist
    assert playlist.active?
    refute other_playlist.active?
  end
end
