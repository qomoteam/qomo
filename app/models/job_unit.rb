class JobUnit < ApplicationRecord

  include StatusAware

  before_destroy :drop_docker_container

  belongs_to :job
  belongs_to :tool

  def out
    if self.docker
      docker_container.logs(stdout: true, stderr: true)
    else
      ''
    end
  end

  def drop_docker_container
    if self.docker
      docker_container.remove(v: true, force: true)
    end
  end

  def docker_container
    Docker::Container.get(self.docker['cid'], {}, Docker::Connection.new(self.docker['host'], {}))
  end

end
