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
class PeopleController < ApplicationController
  ################################################################################
  require_authentication(:except => :show)
  before_filter(:user_check, :except => :show)

  ################################################################################
  without_project

  ################################################################################
  helper(:dashboard)

  ################################################################################
  def show
    @user = User.find(params[:id])

    unless @user.enabled?
      redirect_to(home_url)
      return
    end

    @projects = @user.projects.find(:all, :conditions => {:public => true})

    @pages = Page.find(:all, {
      :include    => [:project],
      :conditions => ['updated_by_id = ? and projects.public = ?', @user.id, true],
      :order      => 'updated_at DESC',
      :limit      => 10,
    })

    unless @user.blogs.empty?
      @blog = @user.blogs.find(:first, :order => :slug)
      @layout_feed = {:blog => @blog, :action => 'articles'}
    end
  end

  ################################################################################
  def edit
  end

  ################################################################################
  def update
    @user.attributes = params[:user]
    @user.policies.each {|p| p.update_from_params(params[:policy])}
    @user.update_description(params[:filtered_text], @user)

    if @user.save and @user.policies.each(&:save)
      redirect_to(:action => 'show', :id => @user)
    else
      render(:action => 'edit')
    end
  end

  ################################################################################
  private

  ################################################################################
  def user_check
    @user = User.find(params[:id])
    return true if current_user.is_root?
    return false unless current_user == @user
    return true
  end

end
################################################################################
