// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
// = require jquery
// = require jquery_ujs
// = require materialize-sprockets
// = require turbolinks
// = require_tree .

$(document).ready(function () {
  // the "href" attribute of .modal-trigger must specify the modal ID that wants to be triggered
  console.log('hi')
  $('.add_btn').leanModal()
})

// FLASH MODE CAROUSEL =========================

$(document).ready(function () {
  $('#viewCarousel').click(function () {
    if ($(this).hasClass('active')) return
    $(this).addClass('active')
    $('#viewGrid').removeClass('active')

    setCarousel()
    $('.thumbs p').eq(0).clone().addClass('floating-thumb').appendTo('#window')
    $('.thumbs').fadeOut(300)
    setTimeout(function () {
      $('.floating-thumb').addClass('animate')
      $('#carousel').delay(200).fadeIn(200, function () {$('.floating-thumb').remove();})
    }, 150)
  })

  $('#viewGrid').click(function () {
    if ($(this).hasClass('active')) return
    $(this).addClass('active')
    $('#viewCarousel').removeClass('active')

    $('#carousel').fadeOut(200, function () {resetCarousel();})
    $("<p class='floating-thumb animate'><span></span><span class='short'></span></p>").appendTo('#window')
    $('.thumbs').show()
    var parentpos = $('#window').offset()
    var childpos = $('.thumbs p').eq(currentSlide - 1).offset()
    $('.thumbs').hide()

    $('.floating-thumb').removeClass('animate').css({'top': (childpos.top - parentpos.top) - 16 + 'px', 'left': (childpos.left - parentpos.left) + 'px', 'transition': '300ms cubic-bezier(0,.93,.33,.99)', 'width': '155px', 'height': '60px', 'padding-top': '121px'})
    $('.thumbs').delay(300).fadeIn(200, function () {$('.floating-thumb').remove()})
  })

  /* ----  Image Gallery Carousel   ---- */

  var carousel = $('#carousel .innerCarousel')
  var carouselSlideWidth = 337
  var currentSlide = 1
  var isAnimating = false
  var carouselSlides = $('.innerCarousel div')


  setCarousel()

  function resetCarousel () {
    $(carouselSlides).find('p').removeClass('current').eq(0).addClass('current')
    $('#carousel .innerCarousel').css('left', '-168px')
    currentSlide = 1
  }

  function setCarousel () {

    // building the width of the casousel
    var carouselWidth = 0
    $('#carousel div').each(function () {
      carouselWidth += carouselSlideWidth
    })

    $(carousel)[0].style = ''
    $(carousel).css('width', carouselWidth)
    // Load Next Image
    $(carouselSlides).eq(currentSlide).prev().find('p').unbind('click').click(function () {
      if ($(this).hasClass('current')) {return;}
      var currentLeft = Math.abs(parseInt($(carousel).css('left')))
      var newLeft = currentLeft - carouselSlideWidth


      if (isAnimating === true) {return;}
      $(carousel).css({'left': '-' + newLeft + 'px',
        'transition': '500ms cubic-bezier(0,.93,.33,.99)'
      })
      isAnimating = true
      $(this).addClass('current')
      $(carouselSlides).eq(currentSlide).find('p')[0].className = ''
      setTimeout(function () {
        isAnimating = false
        currentSlide--
        setCarousel()
      }, 500)
    })

    $(carouselSlides).eq(currentSlide).next().find('p').unbind('click').click(function () {
      if ($(this).hasClass('current')) {return;}
      var currentLeft = Math.abs(parseInt($(carousel).css('left')))
      var newLeft = currentLeft + carouselSlideWidth

      if (isAnimating === true) {return;}
      $(this).addClass('current')
      $(carouselSlides).eq(currentSlide).find('p')[0].className = ''
      $(carousel).css({'left': '-' + newLeft + 'px',
        'transition': '500ms cubic-bezier(0,.93,.33,.99)'
      })
      isAnimating = true
      setTimeout(function () {
        isAnimating = false
        currentSlide++
        setCarousel()
      }, 500)
    })
  }
})

// END  =========================
