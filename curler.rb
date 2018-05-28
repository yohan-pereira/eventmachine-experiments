require 'eventmachine'
require 'em-http-request'

shutdown = false
Signal.trap("INT") { 
  shutdown= true
  puts "shutting down .."
}


requests = 0
batch = 0
total_requests = 0
started = Time.now.to_i
request_limit = 10000

def compute_rate(started, total_requests)
  elapsed_time = Time.now.to_i - started
  puts "Ran for #{elapsed_time} seconds rps is #{total_requests/elapsed_time}"
end

EM.run do
  EM.add_periodic_timer(2) do
    #sleep 30 unless batch == 0
    #sleep 0.01
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

      if(total_requests > request_limit)
        puts "completed"
        shutdown = true
        break
      end

      requests += 1
      connection_options = { :connect_timeout => 8, :inactivity_timeout => 8 }
      http_request = EventMachine::HttpRequest.new('http://localhost:3000/', connection_options).get :query => {'keyname' => 'value'}
      batch1 = batch
      http_request.errback { puts "shit it broke #{batch1} #{i} #{http_request.error}"; requests -= 1}
      http_request.callback {puts "shit works #{batch1} #{i}" ; requests -= 1; total_requests+=1 ; sleep 0.1 }
    end

    if (shutdown && requests == 0)
      puts "done with all requests, exiting"
      compute_rate(started, total_requests)
      EM.stop
    end
  end
end
