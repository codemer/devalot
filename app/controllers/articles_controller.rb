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
class ArticlesController < ApplicationController
  ################################################################################
  require_authentication(:except => [:index, :archive, :show])
  before_filter(:project_uses_blogs)

  ################################################################################
  with_optional_project

  ################################################################################
  tagging_helper_for(Article)
  comments_helper_for(Article)

  ################################################################################
  table_for(Article, :url => :articles_url, :partial => 'admin_table')

  ################################################################################
  before_filter(:lookup_blog)
  before_filter(:calculate_permissions)

  ################################################################################
  def index
    @articles = @blog.articles.find(:all, {
      :order => 'published_on DESC',
      :conditions => {:published => true},
      :limit => Policy.lookup(:front_page_articles).value,
    })

    setup_feed
  end

  ################################################################################
  def show
    @article = @blog.articles.find_by_permalink(params)
    setup_feed
  end

  ################################################################################
  def archive
    if params[:year].blank?
      @all_articles = @blog.articles.find(:all, :order => 'published_on desc', :conditions => {:published => true})
    else
      @articles = @blog.articles.find_in_month(params[:year], params[:month])
    end
  end

  ################################################################################
  def admin
    when_authorized(:condition => (@can_admin_blog or @can_blog))
  end
  
  ################################################################################
  def new
    when_authorized(:condition => @can_blog) do
      @article = Article.new
    end
  end
  
  ################################################################################
  def create
    when_authorized(:condition => @can_blog) do
      @article = @blog.articles.build(params[:article])
      @article.user = current_user
      @article.update_body(params[:body], current_user)
      @article.update_excerpt(params[:excerpt], current_user) unless params[:excerpt][:body].blank?
      saved = @article.save

      @article.tags.add(params[:tags]) if saved and !params[:tags].blank?
      conditional_render(saved, :url => articles_url('show', @article))
    end
  end

  ################################################################################
  def edit
    when_authorized(:condition => can_admin_article?)
  end

  ################################################################################
  def update
    when_authorized(:condition => can_admin_article?) do
      @article.attributes = params[:article]
      @article.update_body(params[:body], current_user)

      if !@article.excerpt.blank? or !params[:excerpt][:body].blank?
        @article.update_excerpt(params[:excerpt], current_user)

        if @article.excerpt.body.blank?
          @article.excerpt.destroy
        end
      end

      conditional_render(@article.save, :url => articles_url('show', @article))
    end
  end

  ################################################################################
  def publish 
    when_authorized(:conditional => can_admin_article?) do
      @article.publish
      @article.save

      render(:update) {|p| p.replace_html(:admin_table, :partial => 'admin_table')}
    end
  end
  ################################################################################
  private

  ################################################################################
  # Allow access to the helpers we created (mostly for the articles_url method)
  include ArticlesHelper

  ################################################################################
  def project_uses_blogs
    return true unless @project
    @project.policies.check(:use_blog_system)
  end

  ################################################################################
  def can_admin_article?
    @article = @blog.articles.find(params[:id])

    return true if @can_admin_blog
    return true if @can_blog and current_user == @article.user

    @article = nil
    return false
  end

  ################################################################################
  def lookup_blog
    # blog can be taken from article id
    if !params[:id].blank? and params[:year].blank? and params[:id].match(/^\d+$/)
      @article = Article.find_by_permalink(params)
      @blog    = @article.blog
      return
    end

    # project blogs
    if @project
      params[:blog] = 'news' if params[:blog].nil?
      @blog = @project.blogs.find_by_slug(params[:blog])
      return unless @blog.nil?
    end

    # user blogs
    unless params[:blog].blank?
      @blog = Blog.find_by_slug(params[:blog], :conditions => {:bloggable_type => 'User'})
      return unless @blog.nil?
    end

    redirect_to(home_url)
    false
  end

  ################################################################################
  def calculate_permissions
    @can_admin_blog = false
    @can_blog = false
  
    case @blog.bloggable_type
    when "Project"
      @can_blog = current_user.can_blog?(@blog.bloggable)
      @can_admin_blog = current_user.can_admin_blog?(@blog.bloggable)
    when "User"
      @can_blog = true if current_user == @blog.bloggable
      @can_admin_blog = @can_blog
    end

    true
  end

  ################################################################################
  def setup_feed
    @layout_feed = {:blog => @blog, :action => 'articles'}
    @layout_feed[:project] = @project if @project
  end

end
################################################################################
