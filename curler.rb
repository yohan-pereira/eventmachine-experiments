require 'eventmachine'
require 'em-http-request'

shutdown = false
Signal.trap("INT") { 
  shutdown= true
  puts "shutting down .."
}


requests = 0
EM.run do
  EM.add_periodic_timer(2) do
    sleep 10
    puts "making requests; currently made requests #{requests}"
    100.times do |i|
      if(shutdown || (requests > 100))
        puts "shutting down or too many requests"
        break
      end  
      requests += 1
      connection_options = { :connect_timeout => 8, :inactivity_timeout => 8 }
      http_request = EventMachine::HttpRequest.new('http://localhost:3000/', connection_options).get :query => {'keyname' => 'value'}
      http_request.errback { puts "shit it broke #{http_request.error}"; requests -= 1}
      http_request.callback {puts "shit works #{i}" ; requests -= 1; sleep 0.1}
    end
    if (shutdown && requests == 0)
      puts "done with all requests, exiting"
      EM.stop
    end
  end
end
