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
