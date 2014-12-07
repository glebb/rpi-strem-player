require "airplay"
require "mplayer-ruby"

class Player
  def initialize(mode)  
    @mode = mode
    @apple_airplay = Airplay["Apple TV"]
    @apple_tv = nil
    @rpi = nil
  end
  
  def switch(mode)
    @mode = mode
  end
  
  def mplayer(stream)
    if @rpi.nil? then
      @rpi = MPlayer::Slave.new stream, :path => '/usr/bin/mplayer'
    else
       @rpi.load_file stream, :no_append
    end
  end

  def airplay(stream)
    if @apple_tv.nil? then
      @apple_tv = @apple_airplay.play stream
    else
      @apple_tv.play stream
    end
  end
  
  def play(stream)
    unless stream.empty?
      if @mode == "RPI" then
        mplayer stream
      else
        stop 
        airplay stream
      end
    end
  end    

  def stop()
    unless @apple_tv.nil? then
      @apple_tv.pause
      @apple_tv.stop
      @apple_tv.cleanup
      @apple_tv = nil
      
    end
    unless @rpi.nil? then
      @rpi.quit
      @rpi = nil
    end
  end      
end