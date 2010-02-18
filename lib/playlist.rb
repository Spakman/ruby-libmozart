require "singleton"
require "ffi"
require_relative "player"

module Mozart
  # Mozart::Playlist is a singleton since libmozart is currently based on a
  # single playlist. I couldn't work out how to implement multiple playlists in
  # Ruby in a solid enough way and map them to the single playlist that is used
  # in C. If libmozart becomes multi-playlist capable then this will change
  # too.
  class Playlist
    attr_accessor :tracks
    attr_reader :name

    extend FFI::Library
    ffi_lib "mozart"
    attach_function :append, :mozart_add_uri_to_playlist, [ :string, :string ], :void
    attach_function :shuffle, :mozart_shuffle, [], :void
    attach_function :unshuffle, :mozart_unshuffle, [], :void
    attach_function :mozart_playlist_shuffled, [], :bool
    attach_function :size, :mozart_get_playlist_size, [], :int
    attach_function :position, :mozart_get_playlist_position, [], :int
    attach_function :mozart_get_active_playlist_name, [], :string
    attach_function :mozart_init_playlist, [ :string ], :int
    attach_function :mozart_remove_playlist, [ :string ], :int

    alias_method :shuffled?, :mozart_playlist_shuffled

    def initialize(name)
      Mozart::Player.instance
      @tracks = []
      if mozart_init_playlist(name) == 0
        @name = name
      else
        raise "Already a playlist called #{name}"
      end
    end

    def clear!
      @tracks = []
      mozart_remove_playlist(@name)
      mozart_init_playlist(@name)
    end

    # Add the track to the playlist and return the Mozart::Playlist.
    def <<(track)
      if track.respond_to? :url
        append track.url, @name
        @tracks << track
      else
        append track, @name
        @tracks << track
      end
      self
    end

    def empty?
      @tracks.size == 0
    end

    def current_track
      @tracks[position-1]
    end

    def size
      @tracks.size
    end

    def active?
      mozart_get_active_playlist_name == @name
    end
  end
end
