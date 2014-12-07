Shoes.setup do
  gem 'mplayer-ruby'
end

require_relative 'player'

Shoes.app width: 480, height: 320, scroll: false, resize: false do #, fullscreen: true
  @radios = {:'Radio Rock' => 'http://83.102.39.40/Radiorock.mp3',
            :'Radio Suomipop' => 'http://rstream2.nelonenmedia.fi/RadioSuomiPop.mp3',
            :'Radio City' => 'http://icelive0.43660-icelive0.cdn.qbrick.com/4916/43660_radio_city.mp3',
            :'Radio JKL' => 'http://icelive0.43660-icelive0.cdn.qbrick.com/9883/43660_RadioJyvaskyla.mp3',
            :'Radio Nova' => 'http://icelive0.41168-icelive0.cdn.qbrick.com/5050/41168_radionova1.mp3',
            :'Radio Aalto' => 'http://rstream2.nelonenmedia.fi/RadioAalto.mp3',
            :'Radio Nostalgia' => 'http://adwzg4.tdf-cdn.com/9201/nrj_113217.mp3',
            :'Radio NRJ' => 'http://adwzg4.tdf-cdn.com/8945/nrj_179479.mp3',
            :'Loop' => 'http://rstream2.nelonenmedia.fi/Loop.mp3',
            :'Yle Puhe' => 'http://195.248.86.134/liveradiopuhe?.wma',
            :'YleX' => 'http://195.248.86.134/liveylex?.wma',
            :'Radio Keski-Suomi' => 'http://195.248.86.134/a_keskisuomi?.wma',
            :'Yle Suomi' => 'http://195.248.86.134/liveradiosuomi?.wma'}  
  
  @player = Player.new "RPI"
  background "#DFA"
  @buttons = {}
  @last = ""
  flow margin: 10, margin_top: 5, margin_bottom: 5, align: "center" do
    flow width: 0.33 do
      @switch = button "Audio out" do
        if @mode.text == "AppleTV" then
          @mode.text = "RPI"
          @plus.show
          @minus.show
        else
          @mode.text = "AppleTV"
          @plus.hide
          @minus.hide
        end
        @player.stop
        @player.switch @mode.text
        r = @rkeys[-1]
        state = get_state r
        if state.nil? then
          @player.play @last
        end
        update_station_button r
        
      end
    end
    flow width: 0.33 do
      @mode = para "RPI", align: "center"
    end
    flow width: 0.33 do
      @stream = para " ", align: "right"
    end
    flow width: 1.0, margin_top: 20 do
      @plus = button "-", align: "center" do
        @player.volume :down
      end
      para "  "
      @minus = button "+", align: "center" do
        @player.volume :up
      end
    end
  end
  
  stack margin: 10 do
    stroke blue
    strokewidth 4
    fill black
    line 0, 0, width - margin * 2, 0
  end
  
  def get_state(r) 
    state = nil
    if @mode.text == "AppleTV" then
      if @radios[r.to_sym].to_s.end_with? "wma" then
        state = "disabled"
      end
    end
    return state
  end
  
  def update_station_button(r)
    unless @station.nil? 
      @station.remove
    end
    @x.append {
      state = get_state r
      @station = button r.to_s, width: 0.6, state: state do
        @player.play @radios[@station.style[:text].to_sym].to_s
        @last = @radios[@station.style[:text].to_sym].to_s
        @stream.text = @station.style[:text].to_s
      end
    }
  end
  
  flow do
    @x = flow width: "80%", margin: 10 do
      @next = button "Select" do
        r = @rkeys.shift
        update_station_button r
        @rkeys.push(r)
      end
      para "   "
      @rkeys = @radios.keys
    end
    
    stack width: "20%", margin: 10 do
      button "Stop", margin_bottom: 10 do
        @player.stop
        @last = ""
        @stream.text = " "
      end
      
      button "Quit", margin_bottom: 10 do
        self.quit
      end
    end
  end  
end
