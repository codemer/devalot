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
# TODO: Need to break this up
class ProjectContext < Radius::Context
  ################################################################################
  def initialize (project, view)
    super()

    @project = project
    @view    = view
    globals.project = @project

    ################################################################################
    define_tag("project", :for => @project)

    ################################################################################
    define_tag("project:description") do |tag|
      @view.render_filtered_text(@project, :description)
    end

    ################################################################################
    define_tag("page") do |tag|
      tag.locals.page = @project.pages.find_by_title(tag.attr['title'])
      tag.expand
    end

    ################################################################################
    define_tag("page:content") do |tag|
      @view.render_filtered_text(tag.locals.page)
    end

    ################################################################################
    define_tag("tickets") do |tag|
      tag.expand
    end

    ################################################################################
    define_tag("tickets:link") do |tag|
      @view.link_to(tag.attr['title'] || "tickets", {
        :controller => 'tickets',
        :action     => 'new',
        :project    => @project,
      })
    end

    ################################################################################
    define_tag(APP_NAME.downcase) do |tag|
      title = tag.attr['title'] || APP_NAME
      %Q(<a href="#{APP_HOME}">#{title}</a>)
    end

    ################################################################################
    define_tag('code') do |tag|
      language = tag.attr['lang'] || 'ruby'
      code = tag.expand.split(/\r?\n/)
      code.shift if code.first.match(/^\s*$/)
      CodeRay.scan(code.join("\n"), language).div(:line_numbers => :table)
    end

  end

end
################################################################################
