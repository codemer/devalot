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
# Methods for both controllers and views
module AuthHelper
  ################################################################################
  # Check to see if a remote web user has been authenticated
  def logged_in?
    !session[:user_id].nil?
  end

  ################################################################################
  # Get the User object for the logged in user
  def current_user
    @current_user ||= (logged_in? ? User.find(session[:user_id]) : User.new)
    @current_user
  end

  ################################################################################
  # Set the logged in user, or log the current user out
  def current_user= (user)
    session[:user_id] = user ? user.id : nil

    if user
      user.last_login = Time.now
      user.save
    else
      reset_session
    end
  end
  
  ################################################################################
  # Ensure that the current user is logged in
  def authenticate
    user = current_user if logged_in?

    if !user or !user.enabled?
      session[:after_login] = request.request_uri
      redirect_to(:controller => 'account', :action => 'login')
      return false
    end

    user
  end
  
  ################################################################################
  # Ensure that the current user is logged in, and is a root user
  def authenticate_root
    user = authenticate or return false
    user.is_root?
  end

  ################################################################################
  # Ensure that the current user has the given permissions for the current
  # project.  Permissions is a list of project based permissions that the
  # current user must have.  The last argument can be a hash with the
  # following keys:
  #
  # * +:or_user_matches+: If set to a User object, return true if that user is the current user.
  # * +:condition+: Returns true if this key is the true value
  #
  # So, why call this method and use one of the options above?  Because this
  # method forces authentication and will always return true for the admin
  # user.
  def authorize (*permissions)
    return false unless user = authenticate
    return true  if user.is_root?

    configuration = {
      :or_user_matches => nil,
      :condition       => :pill,
    }

    configuration.update(permissions.last.is_a?(Hash) ? permissions.pop : {})

    return true if !configuration[:or_user_matches].nil? and current_user == configuration[:or_user_matches]
    return configuration[:condition] unless configuration[:condition] == :pill

    permissions.each do |permission|
      if StatusLevel.column_names.include?(permission.to_s)
        return false unless user.send("#{permission}?")
      else
        return false unless @project
        return false unless user.send("#{permission}?", @project)
      end
    end

    true
  end

end
################################################################################
