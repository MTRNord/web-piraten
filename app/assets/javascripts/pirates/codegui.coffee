class @CodeGUI

  @initialize: (@textAreaId) ->
    @WatchList._initialize()
    @codeMirror = CodeMirror.fromTextArea document.getElementById(textAreaId), {
      lineNumbers: true,
      autofocus: true,
      tabMode: 'spaces',
      enterMode: 'spaces'
      mode: 'ruby',
      theme: 'monokai',
      keymap: 'sublime',
      styleActiveLine: true,
    }

    # just for a nicer visualization, from jQuery UI
    $.extend($.easing,
      {
        easeOutCubic: (x, t, b, c, d) ->
          c * ((t = t / d - 1) * t * t + 1) + b
      }
    )

    @codeMirror.on  "blur", () -> window.isInEditor = false #TODO implement Game class
    @codeMirror.on  "focus", () -> window.isInEditor = true

    @codeMirror.on 'dblclick', @onDoubleClick

    $("#runBtn").click @start
    $("#stopBtn").click @stop

    $('#codeMirror-loading').hide()


  @onDoubleClick = (event) =>
    selection = event.getSelection().trim() # selected word
    cursor = event.getCursor()
    type = event.getTokenTypeAt(cursor)

    # only variables and single words allowed
    if !type? || type != 'variable' || selection.length < 1 || /\s/.test(selection)
      console.log 'Das geklickte Wort kann keine Variable sein'
      return

    if @WatchList.contains selection
      # already in watchlist
      return

    @WatchList.addVariable(selection)
    hoveringSelection = $ "<div class='flying cm-variable'><span>#{selection}</span></div>"

    dropdownToggle = $ '#watchlist-dropdown'
    hoveringSelection.css({
      position: 'absolute'
      top:  window.mouse.y
      left: window.mouse.x
      display: 'block'
      visibility: 'hidden'
      opacity: 1
      'z-index': 5000
    })

    hoveringSelection.appendTo('body')

    $span = hoveringSelection.children('span:first')
    hoveringSelection.css({
      top: window.mouse.y - ($span.height()/2)
      left: window.mouse.x - ($span.width()/2)
      visibility: 'visible'
    })

    hoveringSelection.animate({
        top: dropdownToggle.offset().top
        left: dropdownToggle.offset().left
        opacity: 0.001
      },
      {
        duration: 1500
        easing: 'easeOutCubic'
        complete: () =>
          hoveringSelection.remove()
          @WatchList.increment()
      }
    )

  @toggleSetting: (option, value, def) =>
    if @codeMirror.options[option] != value
      @codeMirror.setOption option, value
    else @codeMirror.setOption option, def


  @toggleCodeEditing = () ->
    $('.code-controls').toggleClass 'hidden'

    #lock CodeMirror
    @toggleSetting 'readOnly', true, false
    @toggleSetting 'styleActiveLine', false, true
    $('.code-wrapper .CodeMirror').toggleClass 'editing-disabled'
    window.isSimulating = !window.isSimulating #TODO Game class
    @clearHighlighting() if !window.isSimulating

  @getCode = () ->
    @codeMirror.getValue()

  @highlightLine: (line) ->
    if @lastLine?
      @codeMirror.removeLineClass @lastLine, 'background', 'processedLine'
#    else
#      # reset everything when simulation starts (again)
#      @clearHighlighting()

    @codeMirror.addLineClass line, 'background', 'processedLine'
    @lastLine = line

  @clearHighlighting = () ->
    @codeMirror.removeLineClass(i, 'background', 'processedLine') for i in [0..@codeMirror.lineCount()]

  @start = () =>
    @toggleCodeEditing()
    webSocket.trigger "simulateGrid", {
      code: CodeGUI.getCode()
      grid: Grid.serialize()
    }

  @stop = () =>
    operationHandler.clear()
    @toggleCodeEditing()
    webSocket.trigger "stopSimulation"




# storing of variables to watch in execution time
class CodeGUI.WatchList

  @_initialize = () ->
    @_$watchlist = $('#watchlist')
    @_$default = $('#watchlist-default')
    @_$size = $('#watchlist-size')
    @_$watchlist.on 'click','.watchlist-remove', @onClick

  @addVariable = (word) ->
    @_$default.hide()
    @_$watchlist.append Config.getWatchListRemoveButtonHTML(word)

  @updateQueueSize = () ->
    watchlist = @get()
    @_$size.html watchlist.length

  @increment = () ->
    @_$size.html parseInt(@_$size.html())+1

  @get = () ->
    watchlist = []
    @_$watchlist.children('li').each () ->
      watchlist.push $(this).text().trim()
    return watchlist

  @contains = (word) ->
    @_$watchlist.children("li:contains('#{word}')").length > 0

  @onClick = (event) =>
    # avoid that bootstrap closes the dropdown
    event.stopPropagation()

    slideDuration = 300
    self = this
    $(event.target).parent().fadeOut({
      duration: slideDuration
      queue: false
      complete: () ->
        $(this).remove()
        self.updateQueueSize()
        # show the default message if the watchlist is empty
        if self._$size.html() < 1 && self._$default.is ':hidden'
          self._$default.fadeIn({
            duration: slideDuration
            queue: false
          })
          .css('display', 'none')
          .slideDown slideDuration
    })
    .slideUp slideDuration