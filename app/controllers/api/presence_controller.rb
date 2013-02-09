class Api::PresenceController < ApplicationController 
  def ping
    # getting here means someone's logged in
    render(json: {})
  end
end
