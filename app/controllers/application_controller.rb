class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :ref_to_cookie

  def mobile_device?
    if session[:mobile_param]
      session[:mobile_param] == '1'
    else
      request.user_agent =~ /Mobile|webOS/
    end
  end

  protected

  def ref_to_cookie
    campaign_ended = Rails.application.config.ended
    return if campaign_ended || !params[:ref]

    unless User.find_by_referral_code(params[:ref]).nil?
      h_ref = { value: params[:ref], expires: 1.week.from_now }
      cookies[:h_ref] = h_ref
    end

    user_agent = request.env['HTTP_USER_AGENT']
    return unless user_agent && !user_agent.include?('facebookexternalhit/1.1')
    redirect_to proc { url_for(params.except(:ref)) }
  end
end
