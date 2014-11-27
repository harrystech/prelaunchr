require 'rails_helper'
require 'securerandom'

describe UsersController, type: :controller do
  before(:each) do
    @email = "#{SecureRandom.hex}@example.com"
  end

  it 'has a referrer when referred' do
    referrer_email = "#{SecureRandom.hex}@example.com"
    referrer = User.create(email: referrer_email)
    cookies[:h_ref] = referrer.referral_code

    post :create, user: {email: @email}
    user = assigns(:user)
    expect(user.referrer.email).to eq(referrer.email)
  end

  context "no referrer" do
    before(:each) do
      post :create, user: {email: @email}
    end

    it 'does not have a referrer when signing up unreferred' do
      user = assigns(:user)
      expect(user.referrer).to be_nil
    end

    it 'redirects to refer-a-friend on creation' do
      expect(response).to redirect_to '/refer-a-friend'
    end

    it 'creates new IpAddress on new email submission' do
      cur_ip = assigns(:cur_ip)
      pending('still figuring out how to test ip address')
      expect(cur_ip.count).to eq(1)
      expect(cur_ip.address).to_not be_nil
    end
  end

  # probably should do more than redirect, but this is current behavior
  it 'redirects to main page when malformed email is submitted' do
    post :create, user: {email: 'notanemail'}
    expect(response).to redirect_to root_path
  end
end
