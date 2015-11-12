module PipelinesHelper

  def export_param(param, owner)
    if param['type'] == 'input'
      param['value'] = "@#{owner.username}:#{param['value']}"
    end
    param
  end

end
