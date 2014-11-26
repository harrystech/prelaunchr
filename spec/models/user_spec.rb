require 'rails_helper'
require 'securerandom'

RSpec.describe User, :type => :model do
  it "should error when saving without email" do
    expect {
      user = User.new
      user.save!
    }.to raise_error(ActiveRecord::RecordInvalid)
  end

  it "should generate a referral code on creation" do
    user = User.new(email: 'user@example.com')
    user.run_callbacks(:create)
    expect(user).to receive(:create_referral_code)
    user.save!
    expect(user.referral_code).to_not be_nil
  end

  it "should send a welcome email on save" do
    user = User.new(email: 'user@example.com')
    user.run_callbacks(:create)
    expect(user).to receive(:send_welcome_email)
    user.save!
  end
end

RSpec.describe UsersHelper do
  describe "replace_if_collision" do
    it "should return the same referral code if there is no collision" do
      referral_code = SecureRandom.hex(5)
      @collision = nil
      candidate = UsersHelper.replace_if_collision(@collision, referral_code)
      expect(referral_code).to eq(candidate)
    end

    it "should return a new referral code if there is a collision" do
      referral_code = SecureRandom.hex(5)
      @collision = referral_code
      candidate = UsersHelper.replace_if_collision(@collision, referral_code)
      expect(referral_code).to_not eq(candidate)
    end
  end
end