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
class HomeController < ApplicationController
  ################################################################################
  without_project

  ################################################################################
  tagging_helper_for(Article)
  helper(:articles)

  @search = ''
  @results = {}

  ################################################################################
  def index
    @layout_feed = {:blog => 'all', :action => 'articles'}

    @projects = Project.find(:all, {
      :order      => :name,
      :conditions => {:public => true},
    })

    @articles = Article.find_public_and_published(Policy.lookup(:front_page_articles).value)
    @popular_tags = Tag.popular
  end

  ################################################################################
  def search
    @search = params[:q]
    offset = params[:o]
    @results = {}
    if (@search != nil)
      search_objects = [ Page, Article ]
      @results = []
      search_objects.each do |obj|
        obj.find_by_contents(@search, { :limit => 100 } ).each do |m|
          @results.push m
        end
      end
      @results = @results.sort{ |a,b| b.ferret_score <=> a.ferret_score }
    end
  end

end
################################################################################
