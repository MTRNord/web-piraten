#= require ./utilities
#= require websocket_rails/main

onOpen = (event) ->
  Utils.log("Connection established!")
#  console.log("Websocket Connection open!")
#  console.log(event)

onClose = (event) ->
  Utils.log("Connection closed!")
#  console.log(event)

onMessage = (event) ->
  Utils.log("Message received:" + event.data)
#  console.log(event)

onError = (event) ->
  Utils.logError("Connection error!")
#  console.log(event)

sendMessage= (message) ->
  Utils.log("Sent: "+message)
  webSocket.send(message)

# establish connection
window.webSocket = new WebSocketRails 'localhost:3000/websocket'
webSocket.on_open    = onOpen
webSocket.on_close   = onClose
webSocket.on_message = onMessage
webSocket.on_error   = onError


# allows to subscribe to several channels
class ChannelHandler

  constructor: (@channelName) ->
    @channel = webSocket.subscribe(channelName, @onSubscribe, @onSubscribeFail)

  onSubscribe: (event) =>
    console.log "Subscribed to channel '#{ @channelName }'!"
    console.log event

  onSubscribeFail: (event) =>
    console.log "Channel '#{ @channelName }' lost connection"
    console.log event


# channel operator for game object operations
class @OperationHandler extends ChannelHandler
#  constructor: (@actionMap) ->
#    super "operations"
#    for action, call of actionMap
#      @channel.bind action, call

  constructor: ()->
    super "operations"
    @lifeTime = 0
    @operationQueue = []
    @channel.bind "line", (data) =>
      @operationQueue.push new Operation("line", data)
    @channel.bind "left", (data) =>
      @operationQueue.push new Operation("left", data)
    @channel.bind "right", (data) =>
      @operationQueue.push new Operation("right", data)
    @channel.bind "move", (data) =>
      @operationQueue.push new Operation("move", data)
    @channel.bind "addbuoy", (data) =>
      @operationQueue.push new Operation("addbuoy", data)

  highlightLine: (line) ->
    line--
    if @lastLine?
      window.codeMirror.removeLineClass @lastLine, 'background', 'processedLine'
    else
      # reset everything when simulation starts (again)
      window.codeMirror.removeLineClass(i, 'background', 'processedLine') for i in [0..window.codeMirror.lineCount()]

    window.codeMirror.addLineClass line, 'background', 'processedLine'
    @lastLine = line

  update: (deltaTime) =>
    if (Config.simulationSpeed > 0 && (@lifeTime % Config.simulationSpeed) != 0) || @operationQueue.length < 1
      @lifeTime++
      return
    repeat = true
    while repeat
      currentOp = @operationQueue.shift() # Operation instance
      @lifeTime++
      repeat = false

      switch currentOp.event
        when "left" then ship.rotateLeft()
        when "right" then ship.rotateRight()
        when "move" then ship.move()
        when "addbuoy" then ship.addbuoy()
        when "line"
          @highlightLine currentOp.data
          repeat = true
        else
          window.Utils.logError "Invalid event: #{currentOp.event} data: #{currentOp.data}"


class @DebugHandler extends ChannelHandler
  logToConsole = (data) ->
    console.log data
  constructor: () ->
    super "debug"
    @channel.bind "console", logToConsole