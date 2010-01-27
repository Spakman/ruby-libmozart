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
    include Singleton

    extend FFI::Library
    ffi_lib "mozart"
    attach_function :append, :mozart_add_uri_to_playlist, [ :string ], :void
    attach_function :mozart_rock_and_roll, [], :void
    attach_function :mozart_quiesce, [], :void
    attach_function :shuffle, :mozart_shuffle, [], :void
    attach_function :unshuffle, :mozart_unshuffle, [], :void
    attach_function :mozart_playlist_shuffled, [], :bool
    attach_function :size, :mozart_get_playlist_size, [], :int

    alias_method :shuffled?, :mozart_playlist_shuffled

    class << self
      alias_method :old_instance, :instance
      alias_method :clear!, :mozart_quiesce

      # Ensure that mozart_init() has been called (and was called only
      # once) using Mozart::Player.instance. Then clear the playlist
      # and get ready to start fresh.
      def instance
        player = Mozart::Player.instance
        old_instance
      end
    end

    def initialize
      @rock_and_roll_called = false
    end

    def clear!
      @rock_and_roll_called = false
      mozart_quiesce
    end

    # Starts the ball rolling, by giving the player a URI. Should only
    # be called once when playing a fresh playlist, since calling it
    # again would skip a track.
    def rock_and_roll
      unless @rock_and_roll_called
        mozart_rock_and_roll
      end
    end

    # Add the URI to the playlist and return the Mozart::Playlist.
    def <<(uri)
      append uri
      self
    end
  end
end
