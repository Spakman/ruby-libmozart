require "test/unit"
require_relative "../lib/playlist"

class PlaylistTest < Test::Unit::TestCase

  def teardown
    Mozart::Playlist.clear!
  end

  def test_create_without_uris
    playlist = Mozart::Playlist.instance
    assert_equal 0, playlist.size
    refute playlist.shuffled?
  end

  def test_clear_playlist
    playlist = Mozart::Playlist.instance
    playlist << Struct.new(:url).new("track1") <<  Struct.new(:url).new("track2")
    assert_equal 2, playlist.size
    playlist.clear!
    assert_equal 0, playlist.size
  end

  def test_shuffle_playlist
    playlist = Mozart::Playlist.instance
    playlist << Struct.new(:url).new("track1") <<  Struct.new(:url).new("track2")
    playlist.shuffle
    assert playlist.shuffled?
  end

  def test_unshuffle_playlist
    playlist = Mozart::Playlist.instance
    playlist << Struct.new(:url).new("track1") <<  Struct.new(:url).new("track2")
    playlist.shuffle
    playlist.unshuffle
    refute playlist.shuffled?
  end
end
