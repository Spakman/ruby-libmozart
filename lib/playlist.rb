require "singleton"
require "ffi"
require_relative "player"

module Mozart
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

    def initialize
      Mozart::Player.instance # ensure libmozart stuff is initialised
      @tracks = {}
      @name = object_id.to_s
      if mozart_init_playlist(@name) == 1
        raise "Already a playlist called #{@name}"
      end
      ObjectSpace.define_finalizer(self, self.class.method(:finalize).to_proc)
    end

    # Removes the playlist from libmozart when this instance is garbage
    # collected.
    def self.finalize(id)
      mozart_remove_playlist id.to_s
    end

    # Add the track to the playlist and return the Mozart::Playlist.
    #
    # The passed track can be a Messier::Track object or a string (like a
    # stream URL).
    def <<(track)
      if track.respond_to? :url
        append track.url, @name
        @tracks[track.url] = track
      else
        append track, @name
        @tracks[track] = track
      end
      self
    end

    def empty?
      size == 0
    end

    def current_track
      @tracks[Mozart::Player.instance.mozart_get_current_uri]
    end

    def active?
      mozart_get_active_playlist_name == @name
    end

    def toggle_shuffled_state
      if shuffled?
        unshuffle
      else
        shuffle
      end
    end
  end
end
