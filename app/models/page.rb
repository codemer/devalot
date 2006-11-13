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
class Page < ActiveRecord::Base
  ################################################################################
  attr_protected(:user_id, :project_id)

  ################################################################################
  validates_presence_of(:title)

  ################################################################################
  validates_uniqueness_of(:title, :scope => :project_id)

  ################################################################################
  # Each page belongs to project
  belongs_to(:project)

  ################################################################################
  # Each page has a user that caused a change
  belongs_to(:user)
  
  ################################################################################
  def self.find_by_title (title)
    if title.match(/^\d+$/)
      self.find(title)
    else
      self.find(:first, :conditions => {:title => title}) or raise "can't find the page with title #{title}"
    end
  end

  ################################################################################
  # Use the page title as the ID
  def to_param
    self.title unless self.title.blank?
  end

end
################################################################################