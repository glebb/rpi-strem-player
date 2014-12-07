require "mplayer-ruby"

class Player
  def initialize(mode)  
    @mode = mode
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
    @apple_tv = Process.fork do
      exec "/usr/local/bin/airplayer " + stream #/Library/Ruby/Gems/2.0.0/gems/airplay-1.0.3/bin/air
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
      Process.kill("HUP", @apple_tv)
      Process.wait
      @apple_tv = nil
    end
    unless @rpi.nil? then
      @rpi.quit
      @rpi = nil
    end
  end      
end
