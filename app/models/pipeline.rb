class Pipeline < ActiveRecord::Base

  scope :pub, -> {where(public: true)}
  scope :belongs_to_user, ->(user) {where(owner: user)}

  belongs_to :owner, class_name: 'User'

  def accession
    "QP-#{self.id}"
  end


  def params_ui
    self.params.collect do |p|
      box = self.boxes[p['box_id']]
      tool = Tool.find box['tool_id']
      p['tool'] = tool
      p['tool_param'] = tool.params.select {|e| e['name'] == p['name']}[0]
      value = box['values'].select {|k, v| k == p['name']}[p['name']]

      if p['tool_param']['options']
        unless value.is_a? Array
          value = [value]
        end
        p['tool_param']['options'].collect do |e|
          if value.include? e['value']
            e['selected'] = true
          else
            e['selected'] = false
          end
        end
      else
        p['tool_param']['value'] = value
      end

      p
    end
  end


  def empty_params
    ep = []
    self.boxes.values.each do |box|
      @tool = Tool.find box['tool_id']
      np = @tool.params
      self.connections.each do |c|
        np.reject! do |e|
          (c['sourceId'] == box['id'] and c['sourceParamName'] == e['name']) or (c['targetId'] == box['id'] and c['targetParamName'] == e['name'])
        end
      end

      box['values'].each do |k, v|
        np.each do |e|
          if e['name'] == k and (v.nil? or v.blank?)
            ep << {tool: @tool, param: e}
          end
        end

      end
    end

    ep
  end

end
