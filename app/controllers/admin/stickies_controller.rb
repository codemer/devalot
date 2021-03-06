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
class Admin::StickiesController < AdminController
  ################################################################################
  table_for(Stickie, :url => {:action => 'list'}, :partial => 'table')

  ################################################################################
  def list
  end

  ################################################################################
  def new
    @stickie = Stickie.new
  end

  ################################################################################
  def create
    @stickie = Stickie.new(params[:stickie])
    @stickie.build_filtered_text(params[:filtered_text])
    @stickie.filtered_text.created_by = current_user
    @stickie.filtered_text.updated_by = current_user
    conditional_render(@stickie.save, :redirect_to => 'list')
  end

  ################################################################################
  def edit
    @stickie = Stickie.find(params[:id])
  end

  ################################################################################
  def update
    @stickie = Stickie.find(params[:id])
    @stickie.attributes = params[:stickie]
    @stickie.filtered_text.attributes = params[:filtered_text]
    @stickie.filtered_text.updated_by = current_user
    conditional_render(@stickie.save && @stickie.filtered_text.save, :redirect_to => 'list')
  end

  ################################################################################
  def destroy
    Stickie.find(params[:id]).destroy
    redirect_to(:action => 'list')
  end

end
################################################################################
