require 'rails_helper'
require 'securerandom'

def generate_email
  "#{SecureRandom.hex}@example.com"
end

describe UsersController, type: :controller do
  describe "new" do
    it 'renders new user/landing page on first visit' do
      get :new
      expect(response).to have_http_status(:success)
    end

    it 'skips first page on saved user\'s second visit' do
      cookies[:h_email] = generate_email
      expect(User).to receive(:find_by_email) { User.new }

      get :new
      expect(response).to redirect_to '/refer-a-friend'
    end
  end

  describe "saving users" do
    before(:each) do
      @email = generate_email
    end

    it 'redirects to refer-a-friend on creation' do
      post :create, user: {email: @email}
      expect(response).to redirect_to '/refer-a-friend'
    end

    it 'has a referrer when referred' do
      referrer_email = "#{SecureRandom.hex}@example.com"
      referrer = User.create(email: referrer_email)
      cookies[:h_ref] = referrer.referral_code

      post :create, user: {email: @email}
      user = assigns(:user)
      expect(user.referrer.email).to eq(referrer.email)
    end

    it 'does not have a referrer when signing up unreferred' do
      post :create, user: {email: @email}
      user = assigns(:user)
      expect(user.referrer).to be_nil
    end

    context 'ip addresses' do
      before(:each) do
        @ip_address = "192.0.2.#{SecureRandom.hex(3)}"
        request.env['HTTP_X_FORWARDED_FOR'] = @ip_address
        post :create, user: {email: @email}
      end

      it 'creates a new IpAddress on new email submission' do
        cur_ip = assigns(:cur_ip)
        expect(cur_ip).to_not be_nil
        expect(cur_ip.count).to eq(1)
        expect(cur_ip.address).to_not be_nil
      end

      it 'increases the count of the IpAddress when then address appears again with same email' do
        post :create, user: {email: @email}
        cur_ip = assigns(:cur_ip)
        expect(cur_ip).to_not be_nil
        expect(cur_ip.count).to eq(2)
      end

      it 'increases the count of the IpAddress when then address appears again with different email' do
        post :create, user: {email: generate_email()}
        cur_ip = assigns(:cur_ip)
        expect(cur_ip.count).to eq(2)
      end

      it 'redirects to the refer a friend page if the ip count is less than 3' do
        post :create, user: {email: generate_email()}
        cur_ip = assigns(:cur_ip)
        expect(response).to redirect_to '/refer-a-friend'
      end

      it 'redirects to landing page when ip address has already appeared 3 times' do
        post :create, user: {email: generate_email()}
        post :create, user: {email: generate_email()}
        post :create, user: {email: generate_email()} # 4th time
        cur_ip = assigns(:cur_ip)
        expect(cur_ip.count).to eq(3)
        expect(response).to redirect_to('/')
      end

      it 'redirects user back to landing page when submitting email twice from different ip addresses' do
        new_address = "192.0.2.#{SecureRandom.hex(3)}"
        request.env['HTTP_X_FORWARDED_FOR'] = new_address
        post :create, user: {email: @email}
        expect(response).to redirect_to('/')
      end
    end

    # probably should do more than redirect, but this is current behavior
    it 'redirects to main page when malformed email is submitted' do
      post :create, user: {email: 'notanemail'}
      expect(response).to redirect_to root_path
    end
  end
end
