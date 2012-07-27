// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require modernizr.custom
//= require jquery
//= require rails
//= require underscore
//= require backbone
//= require backbone-support
//= require mustache
//= require moment
//= require d3.v2
//= require backbone-bootstrap
//= require_tree .

$( document ).ready(function() {
  $( 'select#user_current_company_id' ).live( 'change', function() {
    $( this ).closest( 'form' ).submit();
  });
});
