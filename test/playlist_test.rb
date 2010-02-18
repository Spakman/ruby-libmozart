require "test/unit"
require_relative "../lib/playlist"

class PlaylistTest < Test::Unit::TestCase

  def teardown
    Mozart::Player.quiesce
  end

  def test_create_without_uris
    @playlist = Mozart::Playlist.new("test")
    assert_equal 0, @playlist.size
    refute @playlist.shuffled?
  end

  def test_clear_playlist
    playlist = Mozart::Playlist.new("test")
    playlist << Struct.new(:url).new("track1") <<  Struct.new(:url).new("track2")
    Mozart::Player.instance.playlist = playlist
    assert_equal 2, playlist.size
    playlist.clear!
    sleep 0.2
    assert_equal 0, playlist.size
  end

  def test_clear_empty_playlist
    Mozart::Playlist.new("test").clear!
  end

  def test_shuffle_playlist
    @playlist = Mozart::Playlist.new("test")
    @playlist << Struct.new(:url).new("track1") <<  Struct.new(:url).new("track2")
    @playlist.shuffle
    assert @playlist.shuffled?
  end

  def test_unshuffle_playlist
    @playlist = Mozart::Playlist.new("test")
    @playlist << Struct.new(:url).new("track1") <<  Struct.new(:url).new("track2")
    @playlist.shuffle
    @playlist.unshuffle
    refute @playlist.shuffled?
  end

  def test_duplicate_playlist_name
    @playlist = Mozart::Playlist.new("test")
    assert_raises(RuntimeError) { @playlist = Mozart::Playlist.new("test") }
  end

  def test_active?
    playlist = Mozart::Playlist.new("test")
    other_playlist = Mozart::Playlist.new("test2")
    playlist << Struct.new(:url).new("track1") <<  Struct.new(:url).new("track2")
    Mozart::Player.instance.playlist = playlist
    assert playlist.active?
    refute other_playlist.active?
  end
end
