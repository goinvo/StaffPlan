// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//

//= require modernizr
//= require jquery
//= require jquery-ujs
//= require moment
//= require d3.v2
//= require bootstrap

//= require lodash
//= require backbone
//= require backbone-support
//= require handlebars
//= require keymaster

//= require staffplan-app

//= require_tree ./models
//= require_tree ./collections
//= require_tree ./views
//= require_tree ./templates
//= require_tree ./routers
//= require_tree ./mixins

$( document ).ready(function() {
  $( 'select#user_current_company_id' ).live( 'change', function() {
    $( this ).closest( 'form' ).submit();
  });
  
  $( 'a.chill-out').live('click', function(event) {
    event.stopPropagation();
    event.preventDefault();
    return false;
  });
  
  // key('left, right', function(event) {
  //   $(document.body).trigger('date:changed', {event: event})
  // });
  
  $('.header-typeahead').typeahead({
      source: StaffPlan.typeAhead
  })
  
  $('.quick-jump').on('submit', function(event) {
    event.stopPropagation();
    event.preventDefault();
    StaffPlan.onTypeAhead($(this));
  })
});
