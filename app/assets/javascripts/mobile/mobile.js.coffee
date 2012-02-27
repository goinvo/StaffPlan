$( document ).ready ->
  # attempt to auto-scroll past the URL bar
  setTimeout ->
    $( document.body ).css("minHeight", "#{window.innerHeight + 45}px")
    window.scrollTo(0, 1) if !pageYOffset
  
  # change on staffplan actual_hours
  $( '.content' ).delegate 'input.submit-on-change', 'change', (event) ->
    $( @ ).closest( 'form.work-week-actual' ).trigger 'submit.rails'
  
  $( '.content' ).delegate 'form.work-week-actual', 'ajax:success', (event, responseData, status, jqxhr) ->
    $( @ ).closest( 'li' ).replaceWith( responseData );
  
  $( '.content' ).delegate 'form.work-week-actual', 'ajax:error', (event) ->
    alert('Something really bad happened.  Sorry.')
  
  # next/prev date
  $( '.content' ).delegate 'a.next-previous', 'ajax:success', (event, responseData, status, jqxhr) ->
    $( '.content' ).html( responseData )