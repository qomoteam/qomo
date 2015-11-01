namespace :qomo do
  namespace :tools do
    desc 'QOMO | Load tools bundle'
    task load_bundle: :environment do
      Rake::Task['qomo:tools:fetch_bundle'].invoke
      Rake::Task['qomo:tools:mount'].invoke
    end

    desc 'QOMO | Fetch tools bundle'
    task fetch_bundle: :environment do
      Config.tools.bundle.each do |url|
        puts "Fetch from #{url}: ........"
        `cd #{Config.dir_tools};git clone --depth=1 #{url}`
      end
    end

    desc 'QOMO | Mount all tools in TOOLS_HOME'
    task mount: :environment do
      Dir.glob(File.join Config.dir_tools, '*') do |tooldir|
        tools = Tool.from_dir tooldir
        tools.each { |t| t.save unless Tool.exists?(name: t.name)} if tools
      end
    end
  end


end
