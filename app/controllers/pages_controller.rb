################################################################################
#
# Copyright (C) 2008 Isaac Foraker <isaac@noscience.net>
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
class PagesController < ApplicationController
  ##############################################################################
  require_authentication(:except => [:list, :show, :redraw_page_table])
  require_authorization(:can_create_pages, :only => [:new, :create])

  ##############################################################################
  tagging_helper_for(Page)
  comments_helper_for(Page)

  ##############################################################################
  table_for(Page, :partial => 'list', :url => lambda {|c| {:project => c.send(:project)}})

  ##############################################################################
  def list
  end

  ##############################################################################
  def show
    @layout_feed = {:blog => 'news', :project => @project, :action => 'articles'}
    @layout_feed[:code] = @project.rss_id unless @project.public?
    @page = @project.pages.find_by_slug(params[:id])
    unless @page
      @page = @project.pages.find_by_title(params[:id])
      if @page
        redirect_to(:action => 'show', :id => @page.slug, :project => @project)
      elsif params[:id] == 'index'
        @page = Page.new(:title => 'index', :body => 'Page missing')
      else
        redirect_to(:action => 'list', :project => @project)
      end
    end
  end

  ##############################################################################
  def new
    title = params[:id] || 'New Page'
    slug = title.to_slug
    @page = @project.pages.build(:title => title, :slug => slug)
  end

  ##############################################################################
  def create
    @page = @project.pages.build(params[:page].update(:updated_by_id => current_user.id, :created_by_id => current_user.id))
    conditional_render(@page.save, :id => @page)
  end

  ##############################################################################
  def edit
    @page = @project.pages.find_by_slug(params[:id])
    # Escape any ampersands.
    @page.body.gsub!(/&/,'&amp;')
    when_authorized(:can_edit_pages, :or_user_matches => @page.updated_by)
  end

  ##############################################################################
  def update
    @page = @project.pages.find_by_slug(params[:id])

    when_authorized(:can_edit_pages, :or_user_matches => @page.updated_by) do
      @page.attributes = params[:page].update(:updated_by_id => current_user.id)
      conditional_render(@page.save, :id => @page)
    end
  end

  ##############################################################################
  def destroy
    @page = @project.pages.find_by_slug(params[:id])
    when_authorized(:can_edit_pages, :or_user_matches => @page.updated_by) do
      @page.destroy
      redirect_to(:action => 'list', :project => @project)
    end
  end

  ##############################################################################
  def print
    @page = @project.pages.find_by_slug(params[:id])
    
    render :layout => 'layouts/print'
  end

  ##############################################################################
  def pdf
    @page = @project.pages.find_by_slug(params[:id])
    add_variables_to_assigns
    htmldoc_env = "HTMLDOC_NOCGI=TRUE;export HTMLDOC_NOCGI" 
    generator = IO.popen("#{htmldoc_env};htmldoc -t pdf --path \".;http://#{request[:env]["HTTP_HOST"]}\" --webpage -", "w+")
    generator.puts render_to_string(:layout => 'layouts/print', :action => 'print')
    generator.close_write

    send_data(generator.read, :filename => "#{@page.title}.pdf", :type => "application/pdf")
  end

  ##############################################################################
  def toggle_watch
    @page = @project.pages.find_by_slug(params[:id])
    @watching = @page.watchers.toggle current_user
    render :action => 'pages/watch.rjs'
  end

end
################################################################################
