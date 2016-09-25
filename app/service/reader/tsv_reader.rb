class Reader::TsvReader < Reader::TextReader

  def parse_content(content)
    content.split("\n").collect {|line| line.split("\t")}
  end

end
