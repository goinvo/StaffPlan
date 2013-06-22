class Api::PresenceController < ApplicationController 
  def ping
    # getting here means someone's logged in
    # get the lastest checksum and send it back
    g = Git.open(File.join(Rails.root))
    render(json: {sha: g.log.first.sha})
  end
end
