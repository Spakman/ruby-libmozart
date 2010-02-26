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
    attach_function :mozart_get_current_uri, [], :string
    attach_function :quiesce, :mozart_quiesce, [], :void
    attach_function :player_state, :mozart_get_player_state, [], :gst_state
    attach_function :mozart_get_stream_duration_hms, [ :pointer, :pointer, :pointer ], :int
    attach_function :mozart_get_stream_position_hms, [ :pointer, :pointer, :pointer ], :int
    attach_function :mozart_switch_playlist, [ :string ], :int

    attach_function :play_or_pause, :mozart_play_pause, [], :void
    attach_function :next_track, :mozart_next_track, [], :void
    attach_function :previous_track, :mozart_prev_track, [], :void
    attach_function :mozart_player_seek, [ :string ], :void

    attach_function :mozart_get_tag_artist, [ ], :string
    attach_function :mozart_get_tag_album, [ ], :string
    attach_function :mozart_get_tag_title, [ ], :string


    alias_method :artist, :mozart_get_tag_artist
    alias_method :album, :mozart_get_tag_album
    alias_method :track, :mozart_get_tag_title

    def initialize
      mozart_init nil, nil
    end

    def playlist=(playlist)
      mozart_switch_playlist playlist.name
    end

    # Ensures the player is playing.
    def play
      unless playing?
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

    def seek_forwards
      mozart_player_seek "sseek-fwd"
    end

    def seek_backwards
      mozart_player_seek "sseek-bwd"
    end

    def duration
      hours = FFI::MemoryPointer.new(:pointer)
      minutes = FFI::MemoryPointer.new(:pointer)
      seconds = FFI::MemoryPointer.new(:pointer)
      while mozart_get_stream_duration_hms(hours, minutes, seconds) < 0
        sleep 0.001
      end
      "#{hours.read_int}:#{minutes.read_int.to_s.rjust(2, "0")}:#{seconds.read_int.to_s.rjust(2, "0")}"
    end

    def position
      hours = FFI::MemoryPointer.new(:pointer)
      minutes = FFI::MemoryPointer.new(:pointer)
      seconds = FFI::MemoryPointer.new(:pointer)
      while mozart_get_stream_position_hms(hours, minutes, seconds) < 0
        sleep 0.001
      end
      "#{hours.read_int}:#{minutes.read_int.to_s.rjust(2, "0")}:#{seconds.read_int.to_s.rjust(2, "0")}"
    end
  end
end
