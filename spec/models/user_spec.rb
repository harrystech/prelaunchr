require 'rails_helper'
require 'securerandom'

RSpec.describe User, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
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