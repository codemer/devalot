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
class TicketTableHelper < TableMaker::Proxy
  ################################################################################
  include TimeFormater
  include PeopleHelper
  include ProjectsHelper

  ################################################################################
  columns(:order => [:id, :title, :project, :state, :severity, :priority])
  columns(:include => [:id, :title, :state, :severity, :priority, :assigned_to, :created_on, :updated_on])
  columns(:link => [:id, :title])
  
  ################################################################################
  def url (ticket)
    url_for(:controller => 'tickets', :action => 'show', :id => ticket, :project => ticket.project)
  end

  ################################################################################
  def display_value_for_assigned_to (ticket)
    if ticket.assigned_to
      link_to_person(ticket.assigned_to)
    else
      'no one'
    end
  end

  ################################################################################
  def display_value_for_project (ticket)
    link_to_project(ticket.project)
  end

  ################################################################################
  def display_value_for_state (ticket)
    ticket.state_title
  end

  ################################################################################
  def display_value_for_created_on (ticket)
    format_time_from(ticket.created_on, @controller.current_user)
  end

  ################################################################################
  def display_value_for_updated_on (ticket)
    format_time_from(ticket.updated_on, @controller.current_user)
  end

end
################################################################################
