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
class PositionTableHelper < TableMaker::Proxy
  ################################################################################
  include PeopleHelper
  include TimeFormater

  ################################################################################
  columns(:order => [:user, :role])
  columns(:include => [:user, :role, :created_on])

  ################################################################################
  def display_value_for_controls_column (position)
    result = ''
    result << generate_icon_form('app/pencil.jpg', :url => {:action => 'edit', :id => position, :project => @project})
    result << ' '
    result << generate_icon_form('app/minus.gif',  :confirm => "Remove member #{position.user.name}?", :url => {:action => 'destroy', :id => position, :project => @project})
    result
  end

  ################################################################################
  def heading_for_user
    "Person"
  end

  ################################################################################
  def heading_for_created_on
    "Since"
  end

  ################################################################################
  def display_value_for_user (position)
    link_to_person(position.user)
  end
  
  ################################################################################
  def display_value_for_created_on (position)
    format_time_from(position.created_on, @controller.current_user)
  end

end
################################################################################