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
module FormsHelper
  ################################################################################
  # Generate a form for the given object (optional).  A FormDescription object is
  # passed to the given block to configure the fields of the form.
  def generate_form_for (object=nil, options={}, &block)
    desc = FormDescription.new(object)
    yield(desc)
    concat(generate_form_from(desc, object, options), block)
  end

  ################################################################################
  # Generate a form using an existing form description object.  See
  # generate_form_for for more details.
  def generate_form_from (desc, object=nil, options={})
    result = String.new

    url = {}
    html_options = {}

    if object
      url[:action] = object.new_record? ? 'create' : 'update'
      url[:id] = object.to_param #unless object.new_record?
      html_options[:method] = object.new_record? ? :post : :put
    end

    if request.xhr? or options[:xhr]
      result << form_remote_tag(:url => url, :html => html_options)
    else
      result << form_tag(url, html_options)
    end

    result << %Q(<fieldset>)

    if legend = options.delete(:legend)
      result << %Q(<legend>#{legend}</legend>)
    end

    result << generate_form_fields(desc)
    result << generate_form_buttons(desc)

    result << %Q(</fieldset>)
    result << end_form_tag()

    result
  end

  ################################################################################
  def generate_form_fields (form_description)
    form_description.fields.inject(String.new) do |str, field|
      case field[:type]
      when :text_field, :password_field, :text_area
        generate_para_with_label(field, str) do |str|
          str << self.send("#{field[:type]}_tag", field[:name], field[:value], field[:options])
        end
      when :collection_select
        generate_para_with_label(field, str) do |str|
          str << %Q(<select name="#{field[:name]}">)
          str << options_for_select(field[:collection].map {|o| [o.send(field[:text_method]), o.send(field[:value_method])]}, field[:value])
          str << %Q(</select>)
        end
      end
    end
  end

  ################################################################################
  def generate_form_buttons (form_description)
    result = %Q(<div class="form_buttons">)

    form_description.buttons.inject(result) do |str, button|
      if button[:name] == 'Cancel'
        if cancel = button[:options].delete(:cancel)
          url = url_for(cancel)
        elsif request.env["HTTP_REFERER"]
          url = request.env["HTTP_REFERER"]
        else
          url = home_url()
        end

        str << button_to_function(button[:name], button[:options]) do |page|
          page.redirect_to(url)
        end
      else
        str << submit_tag(button[:name], button[:options])
      end
    end

    result << %Q(<br class="clear"/></div>)
    result
  end

  ################################################################################
  def generate_para_with_label (field, str)
    str << %Q(<p><label for="#{field[:name]}">#{field[:label]}</label>)
    yield(str) if block_given?
    str << %Q(</p>\n)
  end

end
################################################################################