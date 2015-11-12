module PipelinesHelper

  def export_param(param, owner, user)
    if param['type'] == 'input' and user.id != owner.id
      param['value'] = "@#{owner.username}:#{param['value']}"
    end
    param
  end

end
