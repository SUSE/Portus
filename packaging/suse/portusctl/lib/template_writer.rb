# Class taking care of processing the template files used by
# portusctl setup
class TemplateWriter
  # Process the given template and writes it to the final destination
  def self.process(template_name, output, context)
    template = File.join(
      File.expand_path("../../templates", __FILE__),
        template_name)

    conf  = ERB.new(File.read(template), nil, "<>").result(context)

    File.open(output, "w") do |file|
      file.write(conf)
    end
  end
end
