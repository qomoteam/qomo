class JobUnit < ApplicationRecord

  include StatusAware

  before_destroy :drop_docker_container, :drop_runner_script

  belongs_to :job
  belongs_to :tool

  def out
    docker_container&.logs(stdout: true, stderr: true)
  end

  def drop_docker_container
    docker_container&.remove(v: true, force: true)
  end

  def docker_container
    if self.docker
      begin
        return Docker::Container.get(self.docker['cid'], {}, Docker::Connection.new(self.docker['host'], {}))
      rescue
        # ignored
      end
    end
    nil
  end

  def drop_runner_script
    script = File.join(Config.dir_tmp, 'runner-scripts', "#{self.id}.sh")
    if File.exist? script and (not File.directory? script)
      File.delete script
    end
  end

  def end?
    status == 'success' or status == 'fail'
  end

end
