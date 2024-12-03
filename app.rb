require 'faye/websocket'
require 'eventmachine'
require 'json'

PORT = 7798

cmd = [
  '{"cmd": "setuserinfo", "enrollid": 1, "name": "Fulano1", "backupnum": 10, "admin": 0, "record": 12345678}',
  '{"cmd": "setuserinfo", "enrollid": 2, "name": "Fulano2", "backupnum": 10, "admin": 0, "record": 12345678}',
  '{"cmd": "setuserinfo", "enrollid": 8, "name": "Fulano8", "backupnum": 10, "admin": 0, "record": 12345678}',
  '{"cmd": "getalllog", "stn": true}'
]

puts "Starting server on port: #{PORT}"

EM.run do
  # Cria um servidor WebSocket
  EM.start_server('0.0.0.0', PORT, nil) do |socket|
    ws = Faye::WebSocket.new(socket, nil, ping: 15)

    ws.on :open do
      puts "Client connected!"
    end

    ws.on :message do |event|
      puts "Received message from client: #{event.data}"

      if @count.nil? || @count.zero?
        cmd.each do |command|
          ws.send(command)
          puts "Sent message to client: #{command}"
        end
        @count = 1
      end
    end

    ws.on :close do |event|
      puts "Client disconnected! Code: #{event.code}, Reason: #{event.reason}"
      ws = nil
    end
  end
end
