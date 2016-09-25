class Filetype

  attr_reader :name, :desc, :tpl, :reader

  class << self
    def get(kind)
      typemapping = {}
      typemapping.default = Filetype.new(:text, 'Plain Text', 'text')
      typemapping[:directory] = Filetype.new :directory, 'Directory', 'directory'
      typemapping[:nwk] = Filetype.new :nwk, 'Newick', 'nwk', Reader::TextReader.new
      typemapping[:newick] = Filetype.new :nwk, 'Newick', 'nwk', Reader::TextReader.new
      typemapping[:fa] = Filetype.new :fa, 'Fasta', 'fa', Reader::TextReader.new
      typemapping[:fna] = Filetype.new :fa, 'Fasta', 'fa', Reader::TextReader.new
      typemapping[:faa] = Filetype.new :fa, 'Fasta', 'fa', Reader::TextReader.new
      typemapping[:tsv] = Filetype.new :tsv, 'TSV', 'tsv', Reader::TsvReader.new
      typemapping[:csv] = Filetype.new :csv, 'CSV', 'tsv', Reader::CsvReader.new

      typemapping[kind]
    end
  end


  def initialize(name, desc, tpl=Nil, reader=Reader::TextReader.new)
    @name = name
    @desc = desc
    @tpl = tpl || :text
    @reader = reader
  end
end
