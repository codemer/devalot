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
class Page < ActiveRecord::Base
  ################################################################################
  acts_as_ferret :fields => {
    :project => {},
    :title => { :boost => 1.3 },
    :filtered_text_body => { :boost => 1.0 },
    :tags => { :boost => 1.2 }
  },
  :store_class_name => true

  ################################################################################
  attr_protected :project_id

  ################################################################################
  # Each page can have any number of tags
  acts_as_taggable

  ################################################################################
  validates_presence_of :title

  ################################################################################
  validates_uniqueness_of :title, :scope => :project_id

  ################################################################################
  # Each page belongs to a project
  belongs_to :project

  ################################################################################
  has_many :comments, :as => :commentable, :dependent => :destroy
  has_many :watchers, :as => :watchable, :dependent => :destroy

  ################################################################################
  # Each page belongs to a FilteredText where the body is stored
  has_filtered_text

  ################################################################################
  def self.system (title)
    self.find(:first, :conditions => {:title => title, :project_id => nil})
  end

  ################################################################################
  def tagging_added (tagging)
    tagging.project_id = self.project_id
  end

  ################################################################################
  # Use the page title as the ID
  def to_param
    self.title unless self.title.blank?
  end

  ##############################################################################
  def get_watch_record(user)
    Watcher.find :first, :conditions => {:watchable_type => 'Page', :watchable_id => self.id, :user_id => user.id}
  end
  ##############################################################################
  def is_watching?(user)
    w = get_watch_record user
    w != nil
  end

  ##############################################################################
  def toggle_page_watch(user)
    w = get_watch_record user
    watching = w != nil
    if w
      w.destroy
    else
      Watcher.create(:user_id => user.id, :watchable_type => 'Page', :watchable_id => self.id)
    end
    !watching
  end

end
################################################################################
