Shoes.setup do
  gem 'airplay'
  gem 'mplayer-ruby'
end

require_relative 'player'

Shoes.app width: 480, height: 320, scroll: false, resize: false, fullscreen: true do
  @radios = {:'Radio Rock' => 'http://83.102.39.40/Radiorock.mp3',
            :'Radio Suomipop' => 'http://rstream2.nelonenmedia.fi/RadioSuomiPop.mp3',
            :'Radio City' => 'http://icelive0.43660-icelive0.cdn.qbrick.com/4916/43660_radio_city.mp3',
            :'Radio JKL' => 'http://icelive0.43660-icelive0.cdn.qbrick.com/9883/43660_RadioJyvaskyla.mp3',
            :'Radio Nova' => 'http://icelive0.41168-icelive0.cdn.qbrick.com/5050/41168_radionova1.mp3'}  
  
  @player = Player.new "RPI"
  background "#DFA"
  @buttons = {}
  @last = ""
  flow margin: 10, margin_top: 5, margin_bottom: 5, align: "center" do
    flow width: width / 2 - 20 do
      @switch = button "Audio" do
        if @mode.text == "AppleTV" then
          @mode.text = "RPI"
        else
          @mode.text = "AppleTV"
        end
        @player.stop
        @player.switch @mode.text
        @player.play @last
      end
      @mode = para "RPI"
    end
    
    flow width: width / 2 - 20 do
      @stream = para " ", align: "right"
    end
  end
  
  stack margin: 10 do
    stroke blue
    strokewidth 4
    fill black
    line 0, 0, width - margin * 2, 0
  end
  
  flow do
    stack width: "70%", margin: 10 do
      @radios.each do |name, stream|
        temp = button name.to_s, margin_bottom: 10 do
          @stream.text = name.to_s
          @player.play stream.to_s
          @last = stream.to_s
        end
      end
    end
    
    stack width: "30%", margin: 10 do
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
