require "airplay"
require "mplayer-ruby"

class Player
  def initialize(mode)  
    @mode = mode
    @apple_tv = nil
    @apple_airplay = Airplay["Apple TV"]
    @rpi = nil
    @apple_paused = true
  end
  
  def switch(mode)
    @mode = mode
  end
  
  def mplayer(stream)
    if @rpi.nil? then
      @rpi = MPlayer::Slave.new stream, :path => '/usr/local/bin/mplayer'
    else
       @rpi.load_file stream, :no_append
    end
  end

  def airplay(stream)
    @apple_tv = @apple_airplay.play stream
  end
  
  def play(stream)
    unless stream.empty?
      if @mode == "RPI" then
        stop
        mplayer stream
      else 
        airplay stream
      end
    end
  end    

  def stop()
    unless @apple_tv.nil? then
      @apple_tv.pause
    end
    if @rpi != nil then
      @rpi.quit
      @rpi = nil
    end
  end    
  
end