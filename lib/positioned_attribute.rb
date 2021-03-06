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
# Methods for objects that have a global position attribute
module PositionedAttribute
  ################################################################################
  def self.included (base)
    base.extend(ClassMethods)
    base.send(:validates_presence_of, :title)
  end
  
  ######################################################################
  def first?
    self.position == self.class.top_position_in_list
  end

  ######################################################################
  def last?
    self.position == self.class.bottom_position_in_list
  end

  ######################################################################
  # methods that go on the class
  module ClassMethods
    ######################################################################
    def new (*args)
      raise "unexpected arguments to ActiveRecord::Base.new for #{self}" if args.length > 1
      position = bottom_position_in_list+1

      if !args.empty? and !args.first.kind_of?(Hash)
        super(:title => args.first, :position => position)
      else
        super((args[0] || {}).merge(:position => position))
      end
    end

    ######################################################################
    def create (*args)
      obj = new(*args)
      obj.save
      obj
    end

    ######################################################################
    def all
      find(:all, :order => :position)
    end

    ######################################################################
    def bottom_position_in_list
      item = bottom_item
      (item and item.position) ? item.position : 0
    end

    ######################################################################
    def bottom_item
      find(:first, :order => 'position desc')
    end

    ######################################################################
    def top_position_in_list
      item = top_item
      (item and item.position) ? item.position : 0
    end

    ######################################################################
    def top_item 
      find(:first, :order => :position)
    end

  end
end
################################################################################
