class Api::PresenceController < ApplicationController 
  def ping
    # getting here means someone's logged in
    # get the lastest checksum and send it back
    # g = Git.open(File.join(Rails.root))
    render(json: {sha: "f3763485d0e9294512753e8e5bcb051a12ee6235"})
  end
end
