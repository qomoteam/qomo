require 'zip'

class Tool < ApplicationRecord

  attr_accessor :upload

  enum status: {
      inactive: 0,
      active: 1
  }

  default_scope -> { order('name ASC') }

  belongs_to :owner, class_name: 'User'
  belongs_to :category

  belongs_to :tech


  def inputs
    self.params.select { |k| k['type'].downcase == 'input' }
  end


  # @deprecated
  def output
    outputs[0]
  end


  def outputs
    self.params.select { |k| k['type'].downcase == 'output' }
  end


  def io
    inputs << output
  end


  def normal_params
    self.params.reject { |k| %w(input output tmp).include? k['type'].downcase }
  end


  def dirpath_tmp
    File.join(Settings.home, "tmp-#{self.dirname}")
  end


  def dirpath
    File.join Config.dir_tools, self.dirname || self.id
  end

  def copy_upload!
    unless Dir.exist? dirpath
      Dir.mkdir dirpath
    end
    if self.upload
      if self.upload.original_filename.end_with? '.zip'
        Zip::File.open(self.upload.path) do |zip_file|
          zip_file.each do |entry|
            entry.extract("#{dirpath}/#{entry.name}")
          end
        end
      else
        File.open("#{dirpath}/#{self.upload.original_filename}", "wb") { |f| f.write(self.upload.tempfile.read) }
      end
    end
  end


  def files
    pl = self.dirpath.length + 1
    Dir.glob("#{self.dirpath}/**/*").reject {|e| File.directory? e}.collect {|e| {path: e[pl..-1], exe: File.executable?(e)}}
  end


  def self.from_dir(tooldir)
    tools_def = Hash.from_xml File.read(File.join(tooldir, 'tools.xml'))

    tools = tools_def['tools']
    if tools.has_key? 'tool'
      tools = tools['tool']
    end

    tools = [tools] unless tools.is_a? Array
    result = []
    tools.each do |t|
      if t.is_a? Array
        t = t[1]
      end

      tool = Tool.new
      unless t.has_key? 'id'
        puts "ATTR `id` required for this tool: #{tooldir}"
        next
      end

      tool.name = t['name']
      tool.contributors = t['contributors']
      tool.command = t['command'].strip

      tool.category = Category.find_or_create_by name: t['category']
      tool.usage = File.read(File.join tooldir, "#{t['id']}.md")

      tool.dirname = File.basename tooldir

      tool.owner = User.find_by_username Config.admin.username

      params = []

      for k, v in t['params']
        v = [v] unless v.is_a? Array
        for tv in v
          param = {}
          param['type'] = k
          param['name'] = tv['name']
          param['label'] = tv['label']
          param['value'] = tv['value']

          if %w{input output}.include? k
            param['local'] = tv['local'] == 'true'
          end


          if k == 'select'
            param['options'] = tv['option']

            for o in param['options']
              o['selected'] = o['selected'] == 'true'
            end

            if tv['multiple'] and (tv['multiple'] == 'true' or tv['multiple'] == 'on')
              param['multiple'] = true
              param['separator'] = tv['separator'] || ''
            else
              param['multiple'] = false
            end
          end

          params << param
        end
      end

      tool.params = params
      tool.status = 0
      result << tool
    end

    result

  end

end
