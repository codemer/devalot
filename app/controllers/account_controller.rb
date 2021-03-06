################################################################################
#
# Copyright (C) 2006-2007 pmade inc. (Peter Jones pjones@pmade.com)
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
################################################################################
class AccountController < ApplicationController
  ################################################################################
  filter_parameter_logging(:pass) # Don't put passwords in the log file

  ################################################################################
  # we don't work in the context of a project
  without_project

  ################################################################################
  before_filter(:fetch_authenticator)

  ################################################################################
  helper(:dashboard)

  ################################################################################
  def login
    @form_description = EasyForms::Description.new
    @authenticator.form_for_login(@form_description)

    # when we don't have a place to go after login, and the HTTP_REFERER is
    # a URL from this application, go back to that URL after login
    # if session[:after_login].nil? and request.env['HTTP_REFERER']
    #   referer = URI.parse(request.env['HTTP_REFERER'])
    #   here    = URI.parse("http://#{request.env['HTTP_HOST']}")

    #   # kludge: HTTP_REFERER is from our site if it has the same host and port
    #   if "#{referer.host}:#{referer.port}" == "#{here.host}:#{here.port}"
    #     session[:after_login] = request.env['HTTP_REFERER']
    #   end
    # end

    if request.post? and account = @authenticator.authenticate(params) and account.respond_to?(:email)
      login_account(account)
    elsif request.post? and !account.nil?
      @form_description.error(account)
    end

  end

  ################################################################################
  def logout
    if self.current_user.account_id and @authenticator.respond_to?(:logout)
      @authenticator.logout(self.current_user.account_id)
    end

    self.current_user = nil
    redirect_to(home_url)
  end

  ################################################################################
  def new
    return unless check_disable_logins('login')

    unless Policy.check(:allow_open_enrollment) and @authenticator.respond_to?(:form_for_create)
      redirect_to(:action => 'login')
      return
    end
  end

  ################################################################################
  def create
    return unless check_disable_logins('login')

    unless Policy.check(:allow_open_enrollment) and @authenticator.respond_to?(:create_account)
      redirect_to(:action => 'login')
      return
    end

    confirm_url = url_for(:action => 'confirm', :only_path => false)
    @create_result = @authenticator.create_account(params, false, confirm_url)

    if @create_result.respond_to?(:email)
      user = User.from_account(@create_result)
      user.attributes = params[:user]
      user.save

      if @create_result.respond_to?(:enabled?) and !@create_result.enabled?
        redirect_to(:action => 'confirm')
      else
        login_account(@create_result)
      end

    else
      @user = User.new(params[:user])
      render(:action => 'new')
    end
  end

  ################################################################################
  def confirm
    return unless check_disable_logins('login')

    unless Policy.check(:allow_open_enrollment) and @authenticator.respond_to?(:confirm_account)
      redirect_to(:action => 'login')
      return
    end

    if request.post?
      @confirm_result = @authenticator.confirm_account(params)

      if @confirm_result.respond_to?(:email)
        redirect_to(:action => 'login')
      end
    end
  end

  ################################################################################
  private

  ################################################################################
  def login_account (account)
    user = User.from_account(account)
    return false if !user.is_root? and !check_disable_logins

    if !user.enabled?
      error_stickie(_("Your account has been disabled."))
      return false
    end

    # setup the session
    self.current_user = user

    if session[:after_login]
      redirect_to(session[:after_login])
      session[:after_login] = nil
    else
      redirect_to(:controller => 'dashboard')
    end
  end

  ################################################################################
  def check_disable_logins (redirect=nil)
    if Policy.check(:disable_logins)
      error_stickie(_("Sorry, logins have been temporarily disabled. Please check back later."))
      redirect_to(:action => redirect) if redirect
      return false
    end

    true
  end

  ################################################################################
  def fetch_authenticator
    @authenticator = Authenticator.fetch
  end

end
################################################################################
