################################################################################
#
# Copyright (C) 2006 Peter J Jones (pjones@pmade.com)
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
class BuiltinAuthenticator
  ################################################################################
  # Return an EasyForms::Description object that describes the login form
  def self.form_for_login (form)
    form.text_field(:username, 'Username: (e-mail address)')
    form.password_field(:password, 'Password:')
  end

  ################################################################################
  # Return an EasyForms::Description object that describes the new user
  # creation form, if users are allowed to create accounts
  def self.form_for_create (form)
    return unless Policy.check(:allow_open_enrollment)

    form.text_field(:first_name, 'First Name:')
    form.text_field(:last_name, 'Last Name:')
    form.text_field(:email, 'E-mail Address:')
    form.password_field(:password, 'Password:')
    form.password_field(:password2, 'Confirm Password:')
  end

  ################################################################################
  # Given the fields from the login form, return an account object if the user
  # should be allowed to login, and an error message otherwise
  def self.authenticate (params)
    if account = Account.authenticate(params[:username], params[:password]) and account.is_enabled?
      account
    elsif account.nil?
      "The user-name or password you entered is not correct"
    elsif account.require_activation?
      "Your account is awaiting confirmation"
    elsif !account.is_enabled?
      "Your account has been disabled"
    end
  end

  ################################################################################
  # Create an account from the form params from the form_for_create method.
  # You should return a string (or an array of strings) that is presented to
  # the user, or an account object if the user is allowed to login
  # immediately.
  def self.create_account (params)
    return unless Policy.check(:allow_open_enrollment)

    unless params[:password] == params[:password2]
      return "Password and password confirmation don't match"
    end

    account = Account.new(params)
    account.password = params[:password]
    account.require_activation!

    # FIXME, mail out activation code
    
    if account.save
      message  = "Your account has been created, and a confirmation email has been sent.  "
      message << "Please check your email for instructions on how to activate your account."
      message
    else
      errors.full_messages
    end
  end

end
################################################################################
