require "singleton"
require "ffi"
require_relative "playlist"

module Mozart
  class Player
    include Singleton

    extend FFI::Library
    ffi_lib "mozart"
    
    enum :gst_state, [ :pending, :null, :ready, :paused, :playing ]

    attach_function :mozart_init, [ :pointer, :pointer ], :void
    attach_function :quiesce, :mozart_quiesce, [], :void
    attach_function :play_or_pause, :mozart_play_pause, [], :void
    attach_function :next_track, :mozart_next_track, [], :void
    attach_function :previous_track, :mozart_prev_track, [], :void
    attach_function :player_state, :mozart_get_player_state, [], :gst_state

    def initialize
      mozart_init nil, nil
    end

    def playlist
      @playlist ||= Mozart::Playlist.instance
    end

    # Ensures the player is playing.
    def play
      unless playing?
        playlist.rock_and_roll # this is safe to call more than once
        play_or_pause
      end
    end

    # Ensures the player is paused.
    def pause
      unless paused?
        play_or_pause
      end
    end

    def playing?
      player_state == :playing
    end

    def paused?
      player_state == :paused
    end
  end
end
