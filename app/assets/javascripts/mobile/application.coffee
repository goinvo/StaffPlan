$( document ).ready ->
  /mobile/i.test(navigator.userAgent) && !location.hash && setTimeout ->
    window.scrollTo(0, 1) if !pageYOffset
    alert('lol')
  , 1000