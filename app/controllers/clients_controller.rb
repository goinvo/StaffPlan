class ClientsController < ApplicationController
  respond_to :json
  
  before_filter only: [:show, :edit, :update, :destroy] do |c|
    c.find_target
  end

  def index
    respond_with(current_user.current_company.decorate.clients_as_json)
  end

  def show
    respond_with(@client)
  end

  def new
    @client = Client.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @client }
    end
  end

  def create
    @client = Client.new(params[:client])
    
    Client.transaction do
      @client.save!
      current_user.current_company.clients << @client
    end
    
    respond_with(@client)
  end

  def update
    @client.update_attributes(params[:client])
    respond_with(@client)
  end

  def destroy
    @client.destroy
    respond_with(@client)
  end

end
