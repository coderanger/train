# encoding: utf-8

require 'train/file/remote/unix'

module Train
  class File
    class Remote
      class Linux < Train::File::Remote::Unix
        def content
          return @content if defined?(@content)
          @content = @backend.run_command("cat #{@path} || echo -n").stdout
          return @content unless @content.empty?
          @content = nil if directory? or size.nil? or size > 0
          @content
        end
      end
    end
  end
end
