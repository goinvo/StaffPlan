$( document ).ready ->
  # attempt to auto-scroll past the URL bar
  setTimeout ->
    $( document.body ).css("minHeight", "#{window.innerHeight + 45}px")
    window.scrollTo(0, 1) if !pageYOffset
  
  # change on staffplan actual_hours
  $( 'ul.clients-and-projects' ).delegate 'input.submit-on-change', 'change', (event) ->
    $( this ).closest( 'form.work-week-actual' ).trigger 'submit.rails'
  
  $( 'ul.clients-and-projects' ).delegate 'form.work-week-actual', 'ajax:success', (event, responseData, status, jqxhr) ->
    $( this ).closest( 'li' ).replaceWith( responseData );
  
  $( 'ul.clients-and-projects' ).delegate 'form.work-week-actual', 'ajax:error', (event) ->
    alert('Something really bad happened.  Sorry.')