module UsersHelper
  def self.replace_if_collision(collision, referral_code)
    while !collision.nil?
      referral_code = SecureRandom.hex(5)
      collision = User.find_by_referral_code(referral_code)
    end
    referral_code
  end
end
