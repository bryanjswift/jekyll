module Jekyll

  class IncludeTag < Liquid::Tag
    include Convertible

    attr_accessor :site
    attr_accessor :name, :ext, :basename
    attr_accessor :data, :content, :output

    def initialize(tag_name, file, tokens)
      super
      @file = file.strip
    end

    def process(context)
      pieces = @file.split(".")
      alt = context
      pieces.each do |piece|
        if (alt && alt.has_key?(piece))
          alt = alt[piece]
        else
          alt = false
        end
      end
      self.site = context.registers[:site]
      self.name = alt || @file
      self.ext = File.extname(self.name)
      dir = File.join(self.site.source, "_includes")
      if (File.exist? File.join(dir,self.name))
        self.read_yaml(dir, self.name)
      else
        self.data = {}
      end
      self.name
    end

    def render(context)
      if @file !~ /^[a-zA-Z0-9_\/\.-]+$/ || @file =~ /\.\// || @file =~ /\/\./
        return "Include file '#{@file}' contains invalid characters or sequences"
      end
      
      self.process(context)
      Dir.chdir(File.join(self.site.source, '_includes')) do
        choices = Dir['**/*'].reject { |x| File.symlink?(x) }
        if choices.include?(self.name)
          self.content = File.read(self.name)
          do_layout(context,self.site.layouts)
          self.output
        else
          "Included file '#{@file}' not found in _includes directory"
        end
      end
    end

  end

end

Liquid::Template.register_tag('include', Jekyll::IncludeTag)
