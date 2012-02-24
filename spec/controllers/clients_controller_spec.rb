require 'spec_helper'

describe ClientsController do
  
  before(:each) do
    @current_user = login_user
  end
  
  describe "GET index" do
    it "assigns all clients as @clients" do
      company = Factory(:company)
      @current_user.update_attributes(current_company_id: company.id)
      client = Factory(:client)
      company.clients << client
      get :index
      assigns(:clients).should eq([client])
    end
  end

  describe "GET show" do
    it "assigns the requested client as @client" do
      client = Factory(:client)
      get :show, :id => client.id
      assigns(:client).should eq(client)
    end
  end

  describe "GET new" do
    it "assigns a new client as @client" do
      get :new
      assigns(:client).should be_a_new(Client)
    end
  end

  describe "GET edit" do
    it "assigns the requested client as @client" do
      client = Factory(:client)
      get :edit, :id => client.id
      assigns(:client).should eq(client)
    end
  end

  describe "POST create" do
    context "with valid params" do
      it "creates a new Client" do
        expect {
          post :create, :client => Factory.attributes_for(:client)
        }.to change(Client, :count).by(1)
      end

      it "assigns a newly created client as @client" do
        post :create, :client => Factory.attributes_for(:client)
        assigns(:client).should be_a(Client)
        assigns(:client).should be_persisted
      end

      it "redirects to the created client" do
        post :create, :client => Factory.attributes_for(:client)
        # Due to the default_scope being ORDER BY name DESC we need to bypass the scope here
        response.should redirect_to(Client.send(:with_exclusive_scope){Client.last})
      end
    end

    context "with invalid params" do
      it "assigns a newly created but unsaved client as @client" do
        # Trigger the behavior that occurs when invalid params are submitted
        Client.any_instance.expects(:save).returns(false)
        post :create, :client => {}
        assigns(:client).should be_a_new(Client)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        Client.any_instance.expects(:save).returns(false)
        post :create, :client => {}
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    context "with valid params" do
      it "updates the requested client" do
        client = Factory(:client)
        # Assuming there are no other clients in the database, this
        # specifies that the Client created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        client_params = {'name' => 'testy'}
        Client.any_instance.expects(:update_attributes).with(client_params)
        put :update, :id => client.id, :client => client_params
      end

      it "assigns the requested client as @client" do
        client = Factory(:client)
        put :update, :id => client.id, :client => Factory.attributes_for(:client)
        assigns(:client).should eq(client)
      end

      it "redirects to the client" do
        client = Factory(:client)
        put :update, :id => client.id, :client => Factory.attributes_for(:client)
        response.should redirect_to(client)
      end
    end

    context "with invalid params" do
      it "assigns the client as @client" do
        client = Factory(:client)
        # Trigger the behavior that occurs when invalid params are submitted
        Client.any_instance.expects(:save).returns(false)
        put :update, :id => client.id, :client => {}
        assigns(:client).should eq(client)
      end

      it "re-renders the 'edit' template" do
        client = Factory(:client)
        # Trigger the behavior that occurs when invalid params are submitted
        Client.any_instance.expects(:save).returns(false)
        put :update, :id => client.id, :client => {}
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested client" do
      client = Factory(:client)
      expect {
        delete :destroy, :id => client.id
      }.to change(Client, :count).by(-1)
    end

    it "redirects to the clients list" do
      client = Factory(:client)
      delete :destroy, :id => client.id
      response.should redirect_to(clients_url)
    end
  end

end
