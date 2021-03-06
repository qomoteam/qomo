class Filetype

  attr_reader :name, :desc, :icon, :tpl, :reader

  class << self
    def get(kind)
      typemapping = {}
      typemapping.default = Filetype.new :binary, 'Binary', 'fa-file-o'
      typemapping[:directory] = Filetype.new :directory, 'Directory', 'fa-folder', 'directory'
      typemapping[:nwk] = Filetype.new :nwk, 'Newick', 'fa-file-text-o', 'nwk', Reader::TextReader.new
      typemapping[:newick] = Filetype.new :nwk, 'Newick', 'fa-file-text-o', 'nwk', Reader::TextReader.new
      typemapping[:fasta] = Filetype.new :fa, 'Fasta', 'fa-file-text-o', 'fa', Reader::TextReader.new
      typemapping[:fa] = Filetype.new :fa, 'Fasta', 'fa-file-text-o', 'fa', Reader::TextReader.new
      typemapping[:fna] = Filetype.new :fa, 'Fasta', 'fa-file-text-o', 'fa', Reader::TextReader.new
      typemapping[:faa] = Filetype.new :fa, 'Fasta', 'fa-file-text-o', 'fa', Reader::TextReader.new
      typemapping[:fastq] = Filetype.new :fastaq, 'Fastq', 'fa-file-text-o', 'text', Reader::TextReader.new
      typemapping[:tsv] = Filetype.new :tsv, 'TSV', 'fa-file-text-o', 'tsv', Reader::TsvReader.new
      typemapping[:csv] = Filetype.new :csv, 'CSV', 'fa-file-text-o', 'tsv', Reader::CsvReader.new
      typemapping[:axt] = Filetype.new :axt, 'AXT', 'fa-file-text-o', 'text', Reader::TextReader.new
      typemapping[:txt] = Filetype.new :txt, 'Text', 'fa-file-text-o', 'text', Reader::TextReader.new

      typemapping[:sam] = Filetype.new :sam, 'SAM', 'fa-file-text-o', 'text', Reader::TextReader.new
      typemapping[:bam] = Filetype.new :bam, 'BAM', 'fa-file-o'

      typemapping[:png] = Filetype.new :png, 'Image', 'fa-file-image-o', 'image', Reader::NullReader.new
      typemapping[:jpeg] = Filetype.new :jpeg, 'Image', 'fa-file-image-o', 'image', Reader::NullReader.new
      typemapping[:jpg] = Filetype.new :jpg, 'Image', 'fa-file-image-o', 'image', Reader::NullReader.new
      typemapping[:gif] = Filetype.new :gif, 'Image', 'fa-file-image-o', 'image', Reader::NullReader.new

      typemapping[:tif] = Filetype.new :tif, 'Image', 'fa-file-image-o'
      typemapping[:tiff] = Filetype.new :tiff, 'Image', 'fa-file-image-o'
      typemapping[:eps] = Filetype.new :eps, 'Image', 'fa-file-image-o'

      typemapping[:svg] = Filetype.new :svg, 'Image', 'fa-file-image-o', 'svg', Reader::Reader.new


      typemapping[kind]
    end
  end


  def initialize(name, desc, icon='fa-file-o', tpl=:binary, reader=Reader::Reader.new)
    @name = name
    @desc = desc
    @icon = icon
    @tpl = tpl
    @reader = reader
  end

end
