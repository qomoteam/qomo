class Filetype

  attr_reader :name, :desc, :tpl

  class << self
    def get(kind)
      typemapping = {}
      typemapping.default = Filetype.new(:text, 'Plain Text', 'text')
      typemapping[:directory] = Filetype.new :directory, 'Directory', 'directory'
      typemapping[:nwk] = Filetype.new :nwk, 'Newick', 'nwk'
      typemapping[:newick] = Filetype.new :nwk, 'Newick', 'nwk'

      typemapping[kind]
    end
  end


  def initialize(name, desc, tpl=Nil)
    @name = name
    @desc = desc
    @tpl = tpl || :text
  end
end