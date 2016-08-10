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
// = require bootstrap-sprockets
// = require turbolinks
// = require_tree .

$(document).ready(function () {
  console.log('hi')
  $('.add_btn').click(function () {
    console.log('add_btn clicked')
    $('.deck-form').removeClass('hidden')
  })

  $('#cancel').click(function () {
    console.log('cancel clicked')
    $('.deck-form').addClass('hidden')
  })

  $('#js-flip-2').bind('click mouseleave', function () {
    console.log('flip click')
    $('#js-flip-2 .card').toggleClass('flipped')
  })
})
