class Pipeline < ActiveRecord::Base

  acts_as_votable

  belongs_to :owner, class_name: 'User'

  belongs_to :category

  default_scope -> { order('created_at DESC') }

  def accession
    "QP-#{self.id}"
  end


  def merge_params(values)
    boxes = self.boxes.dup
    self.params.collect do |p|
      self.boxes.each do |k, _|
        if k == p['box_id']
          boxes[k]['values'][p['name']] = values.select {|e| e['box_id'] == p['box_id'] and e['name'] == p['name']}[0]['value']
        end
      end
    end
    boxes
  end


  def params_ui
    self.params.collect do |p|
      box = self.boxes[p['box_id']]
      tool = Tool.find box['tool_id']
      p['tool'] = tool
      p['tool_param'] = tool.params.select {|e| e['name'] == p['name']}[0]
      value = box['values'].select {|k, _| k == p['name']}[p['name']]

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


  def export_to_user(user)
    pipeline = self.dup

    pipeline.polish_export_params!
    pipeline.id = nil
    pipeline.title = "My #{ pipeline.title}"
    pipeline.owner = user
    pipeline.shared = false


    pipeline.save
    pipeline
  end


  def polish_export_params!
    jb = self.boxes
    jb.each do |k, v|
      tool = Tool.find v['tool_id']
      tool.inputs.each do |tp|
        v['values'].each do |pk, pv|
          if tp['name'] == pk and (not pv.blank?) and (not pv.start_with? '@')
            jb[k]['values'][pk] = "@#{self.owner.username}:#{pv}"
          end
        end
      end
    end
    self.boxes = jb
  end


end
