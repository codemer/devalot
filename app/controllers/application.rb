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
class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  #protect_from_forgery :secret => '61a39152673f4e5718467f10e3f1cb1d', :only => [:create, :update, :destroy]
  
  ################################################################################
  # Pick a unique cookie name to distinguish our session data from others'
  session(:session_key => "_#{APP_NAME.downcase}_session_id")

  ################################################################################
  # Support for gettext - setup the language zone
  init_gettext("devalot")
  before_filter(:configure_language)

  ################################################################################
  # See the project_object method below
  before_filter(:project_object)

  ################################################################################
  # Controller level tag security
  before_filter(:tag_security)
  
  ################################################################################
  # Prepare URLs for the ActionMailer
  before_filter(:prepare_mailer_urls)

  ################################################################################
  # Add the special controller and view helpers
  add_template_helper(ProjectsHelper)
  add_template_helper(AuthHelper)
  add_template_helper(TimeFormater)

  ################################################################################
  # And some helpers we want to use throughout the app
  helper(:filtered_text)
  helper(:attachments)
  helper(:pages)
  helper(:tickets)
  helper(:people)

  ################################################################################
  protected

  ################################################################################
  # make the AuthHelper calls available to controllers
  include AuthHelper
  include RenderHelper

  ################################################################################
  # The calling controller can work with or without a @project
  def self.with_optional_project
    instance_eval { @with_optional_project = true }
  end

  ################################################################################
  # The calling controller doesn't use @project
  def self.without_project
    instance_eval { @without_project = true }
  end

  ################################################################################
  # Require that the user be authenticated
  def self.require_authentication (options={})
    before_filter(:authenticate, options)
  end

  ################################################################################
  # Require that the current user is a root user
  def self.require_root_user (options={})
    before_filter(:authenticate_root, options)
  end

  ################################################################################
  # Require that the user have a specific set of permissions
  def self.require_authorization (*permissions)
    options = permissions.last.is_a?(Hash) ? permissions.pop : {}
    before_filter(options) {|c| c.instance_eval {authorize(*permissions)}}
  end

  ################################################################################
  # Filter param keys
  def strip_invalid_keys (hash, *keys)
    hash ||= {}
    (hash.keys - keys.map(&:to_s)).each {|key| hash.delete(key)}
  end

  ################################################################################
  # only execute the block when the correct permissions are given, on top of
  # that, redirect if permissions aren't good
  def when_authorized (*permissions, &block)
    if authorize(*permissions)
      yield if block_given?
    else
      redirect_to(request.env["HTTP_REFERER"] ? :back : home_url)
    end
  end

  ################################################################################
  # most controllers need a @project object, this is where it comes from
  def project_object
    return true if self.class.instance_eval { @without_project }

    if params[:project].blank? or (@project = Project.find_by_slug(params[:project])).blank?
      return true if self.class.instance_eval { @with_optional_project }

      # last ditch effort, try to find the project object through some magic
      model_class = Object.const_get(self.class.controller_name.to_s.singularize.camelize)
      if model_class and objs = model_class.find(:all, :conditions => {:id => params[:id].to_i}) and objs.length == 1 and objs.first.respond_to?(:project)
        @project = objs.first.project
      else
        logger.warn("Project.find_by_slug failed for #{params[:project]}")
        redirect_to(home_url)
        return false
      end
    end

    # even if the project is private, admins can see it
    return true if current_user.is_root?

    # if a project is private, and you're not an admin, you must be a project
    # member or have the project secret code to continue.
    unless @project.public? 
      if @project.rss_id == params[:code].to_s.downcase
        return true
      end

      unless logged_in?
        session[:after_login] = request.request_uri
        redirect_to(:controller => 'account', :action => 'login')
        return false
      end

      return true if current_user.projects.include?(@project)
      return false
    end

    true
  end

  ################################################################################
  def tag_security
    return true unless @action_name.match(/^(?:add|remove)_tags_/)
    self.current_user.can_tag?
  end

  ################################################################################
  # Return the current project object (helpful in URL generation)
  def project
    @project
  end
  
  ################################################################################
  # Configure the language to be used by gettext
  # (gettext uses either cookie or parameter automatically.)
  def configure_language
    if (! params[:lang].blank?)
      cookies[:lang] = params[:lang]
    end
  end

  #################################################################################
  # Set a few globals so that URLs will appear in emails correctly.
  # Not very clean, but a major time saver!
  def prepare_mailer_urls
    request = self.request
    ::ActionController::UrlWriter.module_eval do
      default_url_options[:host] = request.host
      if request.port != 80
        default_url_options[:port] = request.port
      end
      protocol = /(.*):\/\//.match(request.protocol)[1] if request.protocol.ends_with?("://")
      default_url_options[:protocol] = protocol
    end
  end

end
################################################################################
