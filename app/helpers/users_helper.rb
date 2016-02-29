module UsersHelper
  def self.unused_referral_code
    referral_code = SecureRandom.hex(5)
    collision = User.find_by_referral_code(referral_code)

    until collision.nil?
      referral_code = SecureRandom.hex(5)
      collision = User.find_by_referral_code(referral_code)
    end
    referral_code
  end
end
