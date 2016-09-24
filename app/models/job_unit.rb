class JobUnit < ApplicationRecord

  include StatusAware

  before_destroy :drop_docker_container

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

end
