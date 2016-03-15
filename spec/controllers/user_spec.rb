require 'rails_helper'
require 'securerandom'

def generate_email
  "#{SecureRandom.hex}@example.com"
end

describe UsersController, type: :controller do
  before do
    allow(Rails.application.config).to receive(:ended) { false }
  end

  describe 'new' do
    before(:each) do
      @referral_code = SecureRandom.hex(5)
    end

    it 'renders new user/landing page on first visit' do
      get :new
      expect(response).to have_http_status(:success)
    end

    it 'skips first page on saved user\'s second visit' do
      cookies[:h_email] = generate_email
      expect(User).to receive(:find_by_email).with(cookies[:h_email]) do
        User.new
      end

      get :new
      expect(response).to redirect_to '/refer-a-friend'
    end

    it 'assigns referral code to cookie if code belongs to user' do
      expect(User).to receive(:find_by_referral_code).with(@referral_code) do
        User.new
      end

      get :new, ref: @referral_code
      expect(cookies[:h_ref]).to eq(@referral_code)
    end

    it 'continues request when user agent is facebookexternalhit/1.1' do
      request.env['HTTP_USER_AGENT'] = 'facebookexternalhit/1.1'

      get :new, ref: @referral_code
      expect(response).to render_template :new
    end

    it 'redirects to intended url when user agent is not facebookexternalhit/1.1' do
      request.env['HTTP_USER_AGENT'] = 'notfacebookexternalhit'

      get :new, ref: @referral_code
      expect(response).to redirect_to root_path
    end
  end

  describe 'refer' do
    it 'should redirect to landing page if there is no email in cookie' do
      get :refer
      expect(response).to redirect_to root_path
    end

    it 'should render /refer-a-friend page if known email exists in cookie' do
      cookies[:h_email] = generate_email
      expect(User).to receive(:find_by_email) { User.new }

      get :refer
      expect(response).to render_template('refer')
    end
  end

  describe 'saving users' do
    before(:each) do
      @email = generate_email
    end

    it 'redirects to /refer-a-friend on creation' do
      post :create, user: { email: @email }
      expect(response).to redirect_to '/refer-a-friend'
    end

    it 'has a referrer when referred' do
      referrer_email = "#{SecureRandom.hex}@example.com"
      referrer = User.create(email: referrer_email)
      cookies[:h_ref] = referrer.referral_code

      post :create, user: { email: @email }
      user = assigns(:user)
      expect(user.referrer.email).to eq(referrer.email)
    end

    it 'does not have a referrer when signing up unreferred' do
      post :create, user: { email: @email }
      user = assigns(:user)
      expect(user.referrer).to be_nil
    end

    context 'ip addresses' do
      before(:each) do
        @ip_address = "192.0.2.#{SecureRandom.hex(3)}"
        request.env['HTTP_X_FORWARDED_FOR'] = @ip_address
        post :create, user: { email: @email }
        @saved_ip = IpAddress.find_by_address @ip_address
      end

      it 'creates a new IpAddress on new email submission' do
        expect(@saved_ip).to_not be_nil
        expect(@saved_ip.count).to eq(1)
        expect(@saved_ip.address).to eq(@ip_address)
      end

      it 'increases the count of the IpAddress when then address appears again with same email' do
        post :create, user: { email: @email }

        updated_ip = IpAddress.find_by_address @ip_address
        expect(updated_ip).to_not be_nil
        expect(updated_ip.count).to eq(2)
      end

      it 'increases the count of the IpAddress when then address appears again with different email' do
        post :create, user: { email: generate_email }

        updated_ip = IpAddress.find_by_address @ip_address
        expect(updated_ip.count).to eq(2)
      end

      it 'redirects to /refer-a-friend if the ip count is less than 3' do
        post :create, user: { email: generate_email }
        expect(response).to redirect_to '/refer-a-friend'
      end

      it 'redirects to landing page when ip has already appeared 3 times' do
        post :create, user: { email: generate_email }
        post :create, user: { email: generate_email }
        post :create, user: { email: generate_email } # 4th time

        expect(response).to redirect_to root_path
      end

      it 'redirects to landing page when resubmitting from different ips' do
        new_address = "192.0.2.#{SecureRandom.hex(3)}"
        request.env['HTTP_X_FORWARDED_FOR'] = new_address
        post :create, user: { email: @email }
        expect(response).to redirect_to('/')
      end
    end

    # probably should do more than redirect, but this is current behavior
    it 'redirects to main page when malformed email is submitted' do
      post :create, user: { email: 'notanemail' }
      expect(response).to redirect_to root_path
    end
  end
end
