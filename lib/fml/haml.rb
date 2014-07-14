require 'haml'

module FML
  class HamlAdapter
    def initialize(formspec, template_dir=nil)
      @formspec = formspec
      if template_dir.nil?
        template_dir = File.join(File.dirname(__FILE__), "haml_templates")
      end

      # In your template dir, there should be a template for "header" and
      # for each form type. They should all end with .haml
      @@templates = {}
      if @@templates.empty?
        Dir.glob(File.join(template_dir, "*.haml")) do |file|
          @@templates[File.basename(file)[0..-6]] = Haml::Engine.new(File.read(file))
        end
      end
    end

    def render()
      locals = {formspec: @formspec}
      out = _render("header", locals)
      @formspec.fieldsets.each do |fieldset|
        fieldset.each do |field|
          locals[:field] = field
          out += _render(field.type, locals)
        end
      end
      out
    end

    def render_show()
      locals = {formspec: @formspec}
      out = _render("header_show", locals)
      @formspec.fieldsets.each do |fieldset|
        fieldset.each do |field|
          locals[:field] = field
          out += _render("#{field.type}_show", locals)
        end
      end
      out
    end

    private

    def _render(template, locals)
      o = Object.new
      @@templates[template].render(o, locals)
    end
  end
end