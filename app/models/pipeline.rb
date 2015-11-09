class Pipeline < ActiveRecord::Base

  scope :pub, -> {where(public: true)}
  scope :belongs_to_user, ->(user) {where(owner: user)}

  belongs_to :owner, class_name: 'User'

  def accession
    "QP-#{self.id}"
  end


  def parametrize
    params = []
    self.boxes.values.each do |box|
      tool = Tool.find(box['tool_id'])
      box['values'].each do |k, v|
        if v.start_with? '~'
          puts tool.params.select {|e| e['name'] == k}[0]
          params << {tool: tool, label: v[2..-2], param: (tool.params.select {|e| e['name'] == k}[0])}
        end
      end
    end
    params
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
