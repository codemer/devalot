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
class Project < ActiveRecord::Base
  ################################################################################
  # basic validations
  validates_presence_of(:name, :slug)

  ################################################################################
  # the slug must be unique, other than the ID, it is the way to find a project
  validates_uniqueness_of(:slug)
  validates_format_of(:slug, :with => /^[\w_-]+$/)

  ################################################################################
  # A project has many tickets
  has_many(:tickets, :order => 'updated_on desc')

  ################################################################################
  # A project has many pages
  has_many(:pages, :order => 'created_on desc')

  ################################################################################
  # Use the project slug when generating URLs
  def to_param
    self.slug unless self.slug.blank?
  end

end
################################################################################
