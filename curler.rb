require 'eventmachine'
require 'em-http-request'

shutdown = false
Signal.trap("INT") { 
  shutdown= true
  puts "shutting down .."
}


requests = 0
batch = 0
EM.run do
  EM.add_periodic_timer(2) do
    sleep 30 unless batch == 0
    batch += 1
    puts "batch #{batch}: making requests; currently made requests #{requests}"

    60.times do |i|
      if(shutdown)
        puts "shutting down"
        break
      end  

      if(requests > 100)
        puts "too many requests"
        break
      end  

      requests += 1
      connection_options = { :connect_timeout => 8, :inactivity_timeout => 8 }
      http_request = EventMachine::HttpRequest.new('http://localhost:3000/', connection_options).get :query => {'keyname' => 'value'}
      batch1 = batch
      http_request.errback { puts "shit it broke #{batch1} #{i} #{http_request.error}"; requests -= 1}
      http_request.callback {puts "shit works #{batch1} #{i}" ; requests -= 1 ; sleep 0.5}
    end

    if (shutdown && requests == 0)
      puts "done with all requests, exiting"
      EM.stop
    end
  end
end
