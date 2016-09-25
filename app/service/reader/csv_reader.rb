class Reader::CsvReader < Reader::TextReader

  def parse_content(content)
    CSV.parse(content)
  end

end
