class Filetype

  attr_reader :name, :desc, :icon, :tpl, :reader

  class << self
    def get(kind)
      typemapping = {}
      typemapping.default = Filetype.new :binary, 'Binary', 'fa-file-o', 'binary'
      typemapping[:directory] = Filetype.new :directory, 'Directory', 'fa-folder', 'directory'
      typemapping[:nwk] = Filetype.new :nwk, 'Newick', 'fa-file-text-o', 'nwk', Reader::TextReader.new
      typemapping[:newick] = Filetype.new :nwk, 'Newick', 'fa-file-text-o', 'nwk', Reader::TextReader.new
      typemapping[:fa] = Filetype.new :fa, 'Fasta', 'fa-file-text-o', 'fa', Reader::TextReader.new
      typemapping[:fna] = Filetype.new :fa, 'Fasta', 'fa-file-text-o', 'fa', Reader::TextReader.new
      typemapping[:faa] = Filetype.new :fa, 'Fasta', 'fa-file-text-o', 'fa', Reader::TextReader.new
      typemapping[:tsv] = Filetype.new :tsv, 'TSV', 'fa-file-text-o', 'tsv', Reader::TsvReader.new
      typemapping[:csv] = Filetype.new :csv, 'CSV', 'fa-file-text-o', 'tsv', Reader::CsvReader.new
      typemapping[:axt] = Filetype.new :axt, 'AXT', 'fa-file-text-o', 'text', Reader::TextReader.new
      typemapping[:txt] = Filetype.new :txt, 'Text', 'fa-file-text-o', 'text', Reader::TextReader.new

      typemapping[kind]
    end
  end


  def initialize(name, desc, icon='fa-file-o', tpl=nil, reader=nil)
    @name = name
    @desc = desc
    @icon = icon
    @tpl = tpl || :text
    @reader = reader
  end

end
