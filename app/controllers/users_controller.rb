class UsersController < ApplicationController
  before_filter :skip_first_page, only: :new
  before_filter :handle_ip, only: :create

  def new
    @bodyId = 'home'
    @is_mobile = mobile_device?

    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  def create
    @user = User.new(email: params[:user][:email])
    @user.referrer = User.find_by_referral_code(cookies[:h_ref])

    if @user.save
      cookies[:h_email] = { value: @user.email }
      redirect_to '/refer-a-friend'
    else
      logger.info("Error saving user with email, #{params[:user][:email]}")
      redirect_to root_path, alert: 'Something went wrong!'
    end
  end

  def refer
    @bodyId = 'refer'
    @is_mobile = mobile_device?

    @user = User.find_by_email(cookies[:h_email])

    respond_to do |format|
      if !@user.nil?
        format.html # refer.html.erb
      else
        format.html { redirect_to root_path, alert: 'Something went wrong!' }
      end
    end
  end

  def policy
  end

  def redirect
    redirect_to root_path, status: 404
  end

  private

  def skip_first_page
    if !Rails.application.config.ended
      email = cookies[:h_email]
      if email and !User.find_by_email(email).nil?
        redirect_to '/refer-a-friend'
      else
        cookies.delete :h_email
      end
    end
  end

  def handle_ip
    return if !User.find_by_email(params[:user][:email]).nil?
    @cur_ip = IpAddress.find_by_address(request.env['HTTP_X_FORWARDED_FOR'])
    if @cur_ip.nil?
      @cur_ip = IpAddress.create(
        address: request.env['HTTP_X_FORWARDED_FOR'], count: 1)
    else
      return redirect_to root_path if @cur_ip.count > 2
    end
  end
end
