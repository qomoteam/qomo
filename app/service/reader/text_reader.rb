class Reader::TextReader

  def read(path, offset, len)
    File.open(path) do |file|
      offset ||= 0
      len ||= 1.kilobytes
      content = ''
      if file.is_rdout?
        parts = Dir.glob(File.join path, 'part-*')
        cpart = nil
        o = offset
        parts.each do |part|
          o -= File.size(part)
          if o < 0
            cpart = part
            break
          end
        end
        read_result = read(cpart, o + File.size(cpart), len)
        read_result[:offset] = offset
        return read_result
      else
        file.seek(offset)
        content = file.read(len)
        unless content.ends_with? "\n"
          left_line = file.gets || ''
          content += left_line
        end
      end

      return {offset: offset, len: content.length, content: parse_content(content)}
    end
  end


  def read_last(path, boffset, len)
    File.open(path) do |file|
      boffset ||= file.size
      len ||= 1.kilobytes
      if file.is_rdout?
        parts = Dir.glob(File.join path, 'part-*')
        cpart = parts[-1]
        read_result = read_last(cpart, File.size(cpart), len)
        read_result[:offset] = read_result[:offset] + parts[0..-2].inject(0) { |sum, x| sum + File.size(x) }
        return read_result
      else
        file.seek([boffset - len, 0].max)
        file.gets
        return read(path, file.pos, boffset - file.pos)
      end
    end
  end


  def parse_content(content)
    content
  end

end
