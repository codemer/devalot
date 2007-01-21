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
module Commentable
  ################################################################################
  module ExtendActionView
    ################################################################################
    def comment_section_for (object)
      result = %Q(<div id="comment_section"><h1>Comments:)

      can_post = 
        if logged_in? and object.respond_to?(:user_can_post_comment) 
          object.user_can_post_comment(current_user)
        else
          logged_in?
        end

      image = ApplicationHelper::ICONS[:plus]
      add_link = link_to_function(image_tag(image[:src], image), nil, :class => image[:class]) do |page|
        page << visual_effect(:toggle_slide, :comment_form)
        page << visual_effect(:scroll_to, :comment_form)
      end

      result << ' ' << add_link if can_post
      result << %Q(</h1>)

      if object.has_comments?
        result << @controller.instance_eval do 
          render_to_string(:partial => 'comments/comment', :collection => object.comments)
        end
      end

      result << %Q(<p>Have something to say? )

      if !logged_in?
        result << link_to('Login', :controller => 'account', :action => 'login') 
        result << " to post a comment."
      elsif object.has_comments?
        result << " Add a comment. " << add_link if can_post
      end

      result << %Q(</p>)

      result << %Q(<div id="comment_form" style="display: none;">)
      result << comment_form(object)
      result << %Q(</div></div>)
      result
    end

    ################################################################################
    def comment_edit_zone (comment)
      result = ''

      if comment.user == current_user or current_user.is_root?
        url = {:action => 'edit_comment', :id => comment.commentable_id, :c => comment.id}
        url[:xhr] = true
        url[:project] = @project if @project

        result << link_with_pencil(url)
        result << ' '

        url[:action] = 'destroy_comment'
        confirm = "Are you sure you want to delete this comment?"
        icon = ApplicationHelper::ICONS[:minus][:src]

        result << generate_icon_form(icon, :url => url, :xhr => true, :confirm => confirm)
        result << %Q(<div id="#{comment.dom_id}_form" style="display: none;"></div>)
      end
    end

    ################################################################################
    def comment_form (object, comment=nil, options={})
      configuration = {
        :dom_id  => 'comment_form',

      }.update(options)

      comment ||= Comment.new
      result = ''

      f = EasyForms::Description.new(comment) do |form|
        form.subform(filtered_text_form(comment.filtered_text, 'Comment'))
      end

      f.button(comment.new_record? ? 'Add' : 'Update')
      f.button('Cancel', :do => lambda {|p| p << visual_effect(:toggle_slide, configuration[:dom_id])})

      url = {:id => object.id}
      url[:action] = comment.new_record? ? 'create_comment' : 'update_comment'
      url[:c] = comment.id unless comment.new_record?
      url[:project] = @project if @project

      result << generate_form_from(f, :url => url, :xhr => true)
      result
    end

  end
end
################################################################################
