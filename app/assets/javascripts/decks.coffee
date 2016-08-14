# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

###global jQuery ###

###!
# jQuery Scrollbox
# (c) 2009-2013 Hunter Wu <hunter.wu@gmail.com>
# MIT Licensed.
#
# http://github.com/wmh/jquery-scrollbox
###

(($) ->

  $.fn.scrollbox = (config) ->
    #default config
    defConfig =
      linear: false
      startDelay: 2
      delay: 3
      step: 5
      speed: 32
      switchItems: 1
      direction: 'vertical'
      distance: 'auto'
      autoPlay: true
      onMouseOverPause: true
      paused: false
      queue: null
      listElement: 'ul'
      listItemElement: 'li'
      infiniteLoop: false
      switchAmount: 0
      afterForward: null
      afterBackward: null
      triggerStackable: false
    config = $.extend(defConfig, config)
    config.scrollOffset = if config.direction == 'vertical' then 'scrollTop' else 'scrollLeft'
    if config.queue
      config.queue = $('#' + config.queue)
    @each ->
      container = $(this)
      containerUL = undefined
      scrollingId = null
      nextScrollId = null
      paused = false
      releaseStack = undefined
      backward = undefined
      forward = undefined
      resetClock = undefined
      scrollForward = undefined
      scrollBackward = undefined
      forwardHover = undefined
      pauseHover = undefined
      switchCount = 0
      stackedTriggerIndex = 0
      if config.onMouseOverPause
        container.bind 'mouseover', ->
          paused = true
          return
        container.bind 'mouseout', ->
          paused = false
          return
      containerUL = container.children(config.listElement + ':first-child')
      # init default switchAmount
      if config.infiniteLoop == false and config.switchAmount == 0
        config.switchAmount = containerUL.children().length

      scrollForward = ->
        if paused
          return
        curLi = undefined
        i = undefined
        newScrollOffset = undefined
        scrollDistance = undefined
        theStep = undefined
        curLi = containerUL.children(config.listItemElement + ':first-child')
        scrollDistance = if config.distance != 'auto' then config.distance else if config.direction == 'vertical' then curLi.outerHeight(true) else curLi.outerWidth(true)
        # offset
        if !config.linear
          theStep = Math.max(3, parseInt((scrollDistance - (container[0][config.scrollOffset])) * 0.3, 10))
          newScrollOffset = Math.min(container[0][config.scrollOffset] + theStep, scrollDistance)
        else
          newScrollOffset = Math.min(container[0][config.scrollOffset] + config.step, scrollDistance)
        container[0][config.scrollOffset] = newScrollOffset
        if newScrollOffset >= scrollDistance
          i = 0
          while i < config.switchItems
            if config.queue and config.queue.find(config.listItemElement).length > 0
              containerUL.append config.queue.find(config.listItemElement)[0]
              containerUL.children(config.listItemElement + ':first-child').remove()
            else
              containerUL.append containerUL.children(config.listItemElement + ':first-child')
            ++switchCount
            i++
          container[0][config.scrollOffset] = 0
          clearInterval scrollingId
          scrollingId = null
          if $.isFunction(config.afterForward)
            config.afterForward.call container,
              switchCount: switchCount
              currentFirstChild: containerUL.children(config.listItemElement + ':first-child')
          if config.triggerStackable and stackedTriggerIndex != 0
            releaseStack()
            return
          if config.infiniteLoop == false and switchCount >= config.switchAmount
            return
          if config.autoPlay
            nextScrollId = setTimeout(forward, config.delay * 10000)
        return

      # Backward
      # 1. If forwarding, then reverse
      # 2. If stoping, then backward once

      scrollBackward = ->
        if paused
          return
        curLi = undefined
        i = undefined
        newScrollOffset = undefined
        scrollDistance = undefined
        theStep = undefined
        # init
        if container[0][config.scrollOffset] == 0
          i = 0
          while i < config.switchItems
            containerUL.children(config.listItemElement + ':last-child').insertBefore containerUL.children(config.listItemElement + ':first-child')
            i++
          curLi = containerUL.children(config.listItemElement + ':first-child')
          scrollDistance = if config.distance != 'auto' then config.distance else if config.direction == 'vertical' then curLi.height() else curLi.width()
          container[0][config.scrollOffset] = scrollDistance
        # new offset
        if !config.linear
          theStep = Math.max(3, parseInt(container[0][config.scrollOffset] * 0.3, 10))
          newScrollOffset = Math.max(container[0][config.scrollOffset] - theStep, 0)
        else
          newScrollOffset = Math.max(container[0][config.scrollOffset] - (config.step), 0)
        container[0][config.scrollOffset] = newScrollOffset
        if newScrollOffset == 0
          --switchCount
          clearInterval scrollingId
          scrollingId = null
          if $.isFunction(config.afterBackward)
            config.afterBackward.call container,
              switchCount: switchCount
              currentFirstChild: containerUL.children(config.listItemElement + ':first-child')
          if config.triggerStackable and stackedTriggerIndex != 0
            releaseStack()
            return
          if config.autoPlay
            nextScrollId = setTimeout(forward, config.delay * 1000)
        return

      releaseStack = ->
        if stackedTriggerIndex == 0
          return
        if stackedTriggerIndex > 0
          stackedTriggerIndex--
          nextScrollId = setTimeout(forward, 0)
        else
          stackedTriggerIndex++
          nextScrollId = setTimeout(backward, 0)
        return

      forward = ->
        clearInterval scrollingId
        scrollingId = setInterval(scrollForward, config.speed)
        return

      backward = ->
        clearInterval scrollingId
        scrollingId = setInterval(scrollBackward, config.speed)
        return

      # Implements mouseover function.

      forwardHover = ->
        config.autoPlay = true
        paused = false
        clearInterval scrollingId
        scrollingId = setInterval(scrollForward, config.speed)
        return

      pauseHover = ->
        paused = true
        return

      resetClock = (delay) ->
        config.delay = delay or config.delay
        clearTimeout nextScrollId
        if config.autoPlay
          nextScrollId = setTimeout(forward, config.delay * 1000)
        return

      if config.autoPlay
        nextScrollId = setTimeout(forward, config.startDelay * 1000)
      # bind events for container
      container.bind 'resetClock', (delay) ->
        resetClock delay
        return
      container.bind 'forward', ->
        if config.triggerStackable
          if scrollingId != null
            stackedTriggerIndex++
          else
            forward()
        else
          clearTimeout nextScrollId
          forward()
        return
      container.bind 'backward', ->
        if config.triggerStackable
          if scrollingId != null
            stackedTriggerIndex--
          else
            backward()
        else
          clearTimeout nextScrollId
          backward()
        return
      container.bind 'pauseHover', ->
        pauseHover()
        return
      container.bind 'forwardHover', ->
        forwardHover()
        return
      container.bind 'speedUp', (event, speed) ->
        if speed == 'undefined'
          speed = Math.max(1, parseInt(config.speed / 2, 10))
        config.speed = speed
        return
      container.bind 'speedDown', (event, speed) ->
        if speed == 'undefined'
          speed = config.speed * 2
        config.speed = speed
        return
      container.bind 'updateConfig', (event, options) ->
        config = $.extend(config, options)
        return
      return

  return
) jQuery

# ---
# generated by js2coffee 2.2.0

# ===================================
# jQuery.event.swipe
# 0.5
# Stephen Band
# Dependencies
# jQuery.event.move 1.2
# One of swipeleft, swiperight, swipeup or swipedown is triggered on
# moveend, when the move has covered a threshold ratio of the dimension
# of the target node, or has gone really fast. Threshold and velocity
# sensitivity changed with:
#
# jQuery.event.special.swipe.settings.threshold
# jQuery.event.special.swipe.settings.sensitivity
((thisModule) ->
  if typeof define == 'function' and define.amd
    # AMD. Register as an anonymous module.
    define [
      'jquery'
      undefined
      'jquery.event.move'
    ], thisModule
  else if typeof module != 'undefined' and module != null and module.exports
    module.exports = thisModule
  else
    # Browser globals
    thisModule jQuery
  return
) (jQuery) ->
  add = jQuery.event.add
  remove = jQuery.event.remove

  trigger = (node, type, data) ->
    jQuery.event.trigger type, data, node
    return

  settings =
    threshold: 0.02
    sensitivity: 10

  moveend = (e) ->
    w = undefined
    h = undefined
    event = undefined
    w = e.currentTarget.offsetWidth
    h = e.currentTarget.offsetHeight
    # Copy over some useful properties from the move event
    event =
      distX: e.distX
      distY: e.distY
      velocityX: e.velocityX
      velocityY: e.velocityY
      finger: e.finger
    # Find out which of the four directions was swiped
    if e.distX > e.distY
      if e.distX > -e.distY
        if e.distX / w > settings.threshold or e.velocityX * e.distX / w * settings.sensitivity > 1
          event.type = 'swiperight'
          trigger e.currentTarget, event
      else
        if -e.distY / h > settings.threshold or e.velocityY * e.distY / w * settings.sensitivity > 1
          event.type = 'swipeup'
          trigger e.currentTarget, event
    else
      if e.distX > -e.distY
        if e.distY / h > settings.threshold or e.velocityY * e.distY / w * settings.sensitivity > 1
          event.type = 'swipedown'
          trigger e.currentTarget, event
      else
        if -e.distX / w > settings.threshold or e.velocityX * e.distX / w * settings.sensitivity > 1
          event.type = 'swipeleft'
          trigger e.currentTarget, event
    return

  getData = (node) ->
    data = jQuery.data(node, 'event_swipe')
    if !data
      data = count: 0
      jQuery.data node, 'event_swipe', data
    data

  jQuery.event.special.swipe = jQuery.event.special.swipeleft = jQuery.event.special.swiperight = jQuery.event.special.swipeup = jQuery.event.special.swipedown =
    setup: (data, namespaces, eventHandle) ->
      `var data`
      data = getData(this)
      # If another swipe event is already setup, don't setup again.
      if data.count++ > 0
        return
      add this, 'moveend', moveend
      true
    teardown: ->
      data = getData(this)
      # If another swipe event is still setup, don't teardown.
      if --data.count > 0
        return
      remove this, 'moveend', moveend
      true
    settings: settings
  return

# ---
# generated by js2coffee 2.2.0

#====================================
# jquery.event.move
#
# 1.3.6
#
# Stephen Band
#
# Triggers 'movestart', 'move' and 'moveend' events after
# mousemoves following a mousedown cross a distance threshold,
# similar to the native 'dragstart', 'drag' and 'dragend' events.
# Move events are throttled to animation frames. Move event objects
# have the properties:
#
# pageX:
# pageY:   Page coordinates of pointer.
# startX:
# startY:  Page coordinates of pointer at movestart.
# distX:
# distY:  Distance the pointer has moved since movestart.
# deltaX:
# deltaY:  Distance the finger has moved since last event.
# velocityX:
# velocityY:  Average velocity over last few events.
((thisModule) ->
  if typeof define == 'function' and define.amd
    # AMD. Register as an anonymous module.
    define [ 'jquery' ], thisModule
  else if typeof module != 'undefined' and module != null and module.exports
    module.exports = thisModule
  else
    # Browser globals
    thisModule jQuery
  return
) (jQuery) ->
  threshold = 6
  add = jQuery.event.add
  remove = jQuery.event.remove

  trigger = (node, type, data) ->
    jQuery.event.trigger type, data, node
    return

  requestFrame = do ->
    window.requestAnimationFrame or window.webkitRequestAnimationFrame or window.mozRequestAnimationFrame or window.oRequestAnimationFrame or window.msRequestAnimationFrame or (fn, element) ->
      window.setTimeout (->
        fn()
        return
      ), 25
  ignoreTags =
    textarea: true
    input: true
    select: true
    button: true
  mouseevents =
    move: 'mousemove'
    cancel: 'mouseup dragstart'
    end: 'mouseup'
  touchevents =
    move: 'touchmove'
    cancel: 'touchend'
    end: 'touchend'
  # Constructors

  Timer = (fn) ->
    `var trigger`
    callback = fn
    active = false
    running = false

    trigger = (time) ->
      if active
        callback()
        requestFrame trigger
        running = true
        active = false
      else
        running = false
      return

    @kick = (fn) ->
      active = true
      if !running
        trigger()
      return

    @end = (fn) ->
      cb = callback
      if !fn
        return
      # If the timer is not running, simply call the end callback.
      if !running
        fn()
      else
        callback = if active then (->
          cb()
          fn()
          return
        ) else fn
        active = true
      return

    return

  # Functions

  returnTrue = ->
    true

  returnFalse = ->
    false

  preventDefault = (e) ->
    e.preventDefault()
    return

  preventIgnoreTags = (e) ->
    # Don't prevent interaction with form elements.
    if ignoreTags[e.target.tagName.toLowerCase()]
      return
    e.preventDefault()
    return

  isLeftButton = (e) ->
    # Ignore mousedowns on any button other than the left (or primary)
    # mouse button, or when a modifier key is pressed.
    e.which == 1 and !e.ctrlKey and !e.altKey

  identifiedTouch = (touchList, id) ->
    i = undefined
    l = undefined
    if touchList.identifiedTouch
      return touchList.identifiedTouch(id)
    # touchList.identifiedTouch() does not exist in
    # webkit yet… we must do the search ourselves...
    i = -1
    l = touchList.length
    while ++i < l
      if touchList[i].identifier == id
        return touchList[i]
    return

  changedTouch = (e, event) ->
    touch = identifiedTouch(e.changedTouches, event.identifier)
    # This isn't the touch you're looking for.
    if !touch
      return
    # Chrome Android (at least) includes touches that have not
    # changed in e.changedTouches. That's a bit annoying. Check
    # that this touch has changed.
    if touch.pageX == event.pageX and touch.pageY == event.pageY
      return
    touch

  # Handlers that decide when the first movestart is triggered

  mousedown = (e) ->
    data = undefined
    if !isLeftButton(e)
      return
    data =
      target: e.target
      startX: e.pageX
      startY: e.pageY
      timeStamp: e.timeStamp
    add document, mouseevents.move, mousemove, data
    add document, mouseevents.cancel, mouseend, data
    return

  mousemove = (e) ->
    data = e.data
    checkThreshold e, data, e, removeMouse
    return

  mouseend = (e) ->
    removeMouse()
    return

  removeMouse = ->
    remove document, mouseevents.move, mousemove
    remove document, mouseevents.cancel, mouseend
    return

  touchstart = (e) ->
    touch = undefined
    template = undefined
    # Don't get in the way of interaction with form elements.
    if ignoreTags[e.target.tagName.toLowerCase()]
      return
    touch = e.changedTouches[0]
    # iOS live updates the touch objects whereas Android gives us copies.
    # That means we can't trust the touchstart object to stay the same,
    # so we must copy the data. This object acts as a template for
    # movestart, move and moveend event objects.
    template =
      target: touch.target
      startX: touch.pageX
      startY: touch.pageY
      timeStamp: e.timeStamp
      identifier: touch.identifier
    # Use the touch identifier as a namespace, so that we can later
    # remove handlers pertaining only to this touch.
    add document, touchevents.move + '.' + touch.identifier, touchmove, template
    add document, touchevents.cancel + '.' + touch.identifier, touchend, template
    return

  touchmove = (e) ->
    data = e.data
    touch = changedTouch(e, data)
    if !touch
      return
    checkThreshold e, data, touch, removeTouch
    return

  touchend = (e) ->
    template = e.data
    touch = identifiedTouch(e.changedTouches, template.identifier)
    if !touch
      return
    removeTouch template.identifier
    return

  removeTouch = (identifier) ->
    remove document, '.' + identifier, touchmove
    remove document, '.' + identifier, touchend
    return

  # Logic for deciding when to trigger a movestart.

  checkThreshold = (e, template, touch, fn) ->
    distX = touch.pageX - (template.startX)
    distY = touch.pageY - (template.startY)
    # Do nothing if the threshold has not been crossed.
    if distX * distX + distY * distY < threshold * threshold
      return
    triggerStart e, template, touch, distX, distY, fn
    return

  handled = ->
    # this._handled should return false once, and after return true.
    @_handled = returnTrue
    false

  flagAsHandled = (e) ->
    e._handled()
    return

  triggerStart = (e, template, touch, distX, distY, fn) ->
    node = template.target
    touches = undefined
    time = undefined
    touches = e.targetTouches
    time = e.timeStamp - (template.timeStamp)
    # Create a movestart object with some special properties that
    # are passed only to the movestart handlers.
    template.type = 'movestart'
    template.distX = distX
    template.distY = distY
    template.deltaX = distX
    template.deltaY = distY
    template.pageX = touch.pageX
    template.pageY = touch.pageY
    template.velocityX = distX / time
    template.velocityY = distY / time
    template.targetTouches = touches
    template.finger = if touches then touches.length else 1
    # The _handled method is fired to tell the default movestart
    # handler that one of the move events is bound.
    template._handled = handled
    # Pass the touchmove event so it can be prevented if or when
    # movestart is handled.

    template._preventTouchmoveDefault = ->
      e.preventDefault()
      return

    # Trigger the movestart event.
    trigger template.target, template
    # Unbind handlers that tracked the touch or mouse up till now.
    fn template.identifier
    return

  # Handlers that control what happens following a movestart

  activeMousemove = (e) ->
    timer = e.data.timer
    e.data.touch = e
    e.data.timeStamp = e.timeStamp
    timer.kick()
    return

  activeMouseend = (e) ->
    event = e.data.event
    timer = e.data.timer
    removeActiveMouse()
    endEvent event, timer, ->
      # Unbind the click suppressor, waiting until after mouseup
      # has been handled.
      setTimeout (->
        remove event.target, 'click', returnFalse
        return
      ), 0
      return
    return

  removeActiveMouse = (event) ->
    remove document, mouseevents.move, activeMousemove
    remove document, mouseevents.end, activeMouseend
    return

  activeTouchmove = (e) ->
    event = e.data.event
    timer = e.data.timer
    touch = changedTouch(e, event)
    if !touch
      return
    # Stop the interface from gesturing
    e.preventDefault()
    event.targetTouches = e.targetTouches
    e.data.touch = touch
    e.data.timeStamp = e.timeStamp
    timer.kick()
    return

  activeTouchend = (e) ->
    event = e.data.event
    timer = e.data.timer
    touch = identifiedTouch(e.changedTouches, event.identifier)
    # This isn't the touch you're looking for.
    if !touch
      return
    removeActiveTouch event
    endEvent event, timer
    return

  removeActiveTouch = (event) ->
    remove document, '.' + event.identifier, activeTouchmove
    remove document, '.' + event.identifier, activeTouchend
    return

  # Logic for triggering move and moveend events

  updateEvent = (event, touch, timeStamp, timer) ->
    time = timeStamp - (event.timeStamp)
    event.type = 'move'
    event.distX = touch.pageX - (event.startX)
    event.distY = touch.pageY - (event.startY)
    event.deltaX = touch.pageX - (event.pageX)
    event.deltaY = touch.pageY - (event.pageY)
    # Average the velocity of the last few events using a decay
    # curve to even out spurious jumps in values.
    event.velocityX = 0.3 * event.velocityX + 0.7 * event.deltaX / time
    event.velocityY = 0.3 * event.velocityY + 0.7 * event.deltaY / time
    event.pageX = touch.pageX
    event.pageY = touch.pageY
    return

  endEvent = (event, timer, fn) ->
    timer.end ->
      event.type = 'moveend'
      trigger event.target, event
      fn and fn()
    return

  # jQuery special event definition

  setup = (data, namespaces, eventHandle) ->
    # Stop the node from being dragged
    #add(this, 'dragstart.move drag.move', preventDefault);
    # Prevent text selection and touch interface scrolling
    #add(this, 'mousedown.move', preventIgnoreTags);
    # Tell movestart default handler that we've handled this
    add this, 'movestart.move', flagAsHandled
    # Don't bind to the DOM. For speed.
    true

  teardown = (namespaces) ->
    remove this, 'dragstart drag', preventDefault
    remove this, 'mousedown touchstart', preventIgnoreTags
    remove this, 'movestart', flagAsHandled
    # Don't bind to the DOM. For speed.
    true

  addMethod = (handleObj) ->
    # We're not interested in preventing defaults for handlers that
    # come from internal move or moveend bindings
    if handleObj.namespace == 'move' or handleObj.namespace == 'moveend'
      return
    # Stop the node from being dragged
    add this, 'dragstart.' + handleObj.guid + ' drag.' + handleObj.guid, preventDefault, undefined, handleObj.selector
    # Prevent text selection and touch interface scrolling
    add this, 'mousedown.' + handleObj.guid, preventIgnoreTags, undefined, handleObj.selector
    return

  removeMethod = (handleObj) ->
    if handleObj.namespace == 'move' or handleObj.namespace == 'moveend'
      return
    remove this, 'dragstart.' + handleObj.guid + ' drag.' + handleObj.guid
    remove this, 'mousedown.' + handleObj.guid
    return

  jQuery.event.special.movestart =
    setup: setup
    teardown: teardown
    add: addMethod
    remove: removeMethod
    _default: (e) ->
      event = undefined
      data = undefined
      # If no move events were bound to any ancestors of this
      # target, high tail it out of here.

      update = (time) ->
        updateEvent event, data.touch, data.timeStamp
        trigger e.target, event
        return

      if !e._handled()
        return
      event =
        target: e.target
        startX: e.startX
        startY: e.startY
        pageX: e.pageX
        pageY: e.pageY
        distX: e.distX
        distY: e.distY
        deltaX: e.deltaX
        deltaY: e.deltaY
        velocityX: e.velocityX
        velocityY: e.velocityY
        timeStamp: e.timeStamp
        identifier: e.identifier
        targetTouches: e.targetTouches
        finger: e.finger
      data =
        event: event
        timer: new Timer(update)
        touch: undefined
        timeStamp: undefined
      if e.identifier == undefined
        # We're dealing with a mouse
        # Stop clicks from propagating during a move
        add e.target, 'click', returnFalse
        add document, mouseevents.move, activeMousemove, data
        add document, mouseevents.end, activeMouseend, data
      else
        # We're dealing with a touch. Stop touchmove doing
        # anything defaulty.
        e._preventTouchmoveDefault()
        add document, touchevents.move + '.' + e.identifier, activeTouchmove, data
        add document, touchevents.end + '.' + e.identifier, activeTouchend, data
      return
  jQuery.event.special.move =
    setup: ->
      # Bind a noop to movestart. Why? It's the movestart
      # setup that decides whether other move events are fired.
      add this, 'movestart.move', jQuery.noop
      return
    teardown: ->
      remove this, 'movestart.move', jQuery.noop
      return
  jQuery.event.special.moveend =
    setup: ->
      # Bind a noop to movestart. Why? It's the movestart
      # setup that decides whether other move events are fired.
      add this, 'movestart.moveend', jQuery.noop
      return
    teardown: ->
      remove this, 'movestart.moveend', jQuery.noop
      return
  add document, 'mousedown.move', mousedown
  add document, 'touchstart.move', touchstart
  # Make jQuery copy touch event properties over to the jQuery event
  # object, if they are not already listed. But only do the ones we
  # really need. IE7/8 do not have Array#indexOf(), but nor do they
  # have touch events, so let's assume we can ignore them.
  if typeof Array::indexOf == 'function'
    ((jQuery) ->
      props = [
        'changedTouches'
        'targetTouches'
      ]
      l = props.length
      while l--
        if jQuery.event.props.indexOf(props[l]) == -1
          jQuery.event.props.push props[l]
      return
    ) jQuery
  return

# ---
# generated by js2coffee 2.2.0
