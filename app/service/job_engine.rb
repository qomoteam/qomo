require 'rgl/adjacency'
require 'rgl/topsort'

class JobEngine

  def initialize(user_id, datastore)
    @user_id = user_id
    @datastore = datastore
  end


  def submit(job_name, boxes, conns)
    job_id = SecureRandom.uuid
    job = Job.new id: job_id, user_id: @user_id, name: job_name

    result = {
        success: true,
        job_id: job_id,
        errors: []
    }

    outdir = job.outdir
    @datastore.mkdir! outdir

    env = {}
    env['HADOOP_USER_NAME'] = Config.hadoop.username

    units = {}

    #Fill the blank output param
    boxes.each do |k, v|
      tool = Tool.find v['tool_id']
      tool.params.each do |e|
        if e['type'] == 'tmp'
          boxes[k]['values'][e['name']] = File.join outdir, '.tmp', SecureRandom.uuid
        end

        v['values'].each do |ka, va|
          if e['name'] == ka
            if e['type'] == 'output'
              if va.blank?
                boxes[k]['values'][ka] = File.join outdir, '.tmp', SecureRandom.uuid
              else
                boxes[k]['values'][ka] = File.join outdir, va
              end
            end
          end
        end
      end
    end

    #Copy output param to input param for connected tools
    dg = RGL::DirectedAdjacencyGraph.new
    conns.each do |e|
      dg.add_edge e['sourceId'], e['targetId']

      if boxes[e['targetId']]['values'][e['targetParamName']].blank?
        boxes[e['targetId']]['values'][e['targetParamName']] = boxes[e['sourceId']]['values'][e['sourceParamName']]
      else
        boxes[e['targetId']]['values'][e['targetParamName']] += ",#{boxes[e['sourceId']]['values'][e['sourceParamName']]}"
      end
    end

    #Generate commands
    #TODO rename variable `k, v`
    boxes.each do |k, v|
      tool = Tool.find v['tool_id']
      unit_id = SecureRandom.uuid
      command = tool.command.dup

      pvalues = v['values']

      # Validate all params are set correctly (not null, etc.)
      tool.params.each do |te|
        pv = pvalues[te['name']]
        if pv&.blank?
          result[:success] = false
          result[:errors] << {box_id: k, param: te['name'], msg: 'need value to be set'}
        end
      end

      rendered_params = {}
      pvalues.each do |ka, va|
        if va.kind_of? Array
          separator = ','
          tool.params.each do |p|
            separator = p['separator'] || separator if p['name'] == ka
          end
          va = va.join separator
        end

        #TODO check this and rename variable `e`
        e = tool.params.find { |e| e['name'] == ka }
        if e
          case e['type']
            when 'input'
              va = va.split ','
              va = va.collect do |ev|
                if ev.start_with? '@'
                  username = ev[1, ev.index(':')-1]
                  user = User.find_by username: username
                  # TODO: Remove this ugly implementation
                  ud = Datastore.new user.id, Config.dir_users
                  ev = ud.apath ev[ev.index(':')+1 .. -1]
                else
                  ev = @datastore.apath ev
                end
                ev
              end

              va = va.join ','
              va = '"' + va + '"'

            when 'output'
              va = @datastore.apath va
              va = '"' + va + '"'
            when 'tmp'
              va = @datastore.apath "#{outdir}/.tmp/#{unit_id}"
              va = '"' + va + '"'
            else
              # No-op
          end
        end
        rendered_params[ka] = va
      end

      command = inject_param command, rendered_params
      units[k] = {id: unit_id, tool_id: tool.id, params: tool.params, command: command, wd: tool.dirpath, env: env}
    end

    unless result[:success]
      @datastore.delete! outdir
      return result
    end

    ordere_units = dg.topsort_iterator.to_a

    if ordere_units.length == 0
      ordere_units = units.values
    else
      ordere_units = ordere_units.collect do |e|
        units[e]
      end
    end

    # Persist to DB and submit to job engine only when everything is OK
    if result[:success]
      ordere_units.each_with_index do |u, idx|
        ju = JobUnit.new u
        ju.job_id = job_id
        ju.idx = idx
        ju.save
      end
      job.save

      #TODO Try catch here!
      RMQ.new.publish 'jobs', {id: job_id, units: ordere_units}
    else
      # TODO maybe we should use exception to do this cleanup
      @datastore.delete! outdir
    end

    result
  end


  def inject_param(command, rendered_params)
    eval "\"#{command}\"", CommandBinding.new(rendered_params).get_binding
  end


  class CommandBinding

    STREAMING_JAR = Config.dir_lib Config.lib.streaming

    def initialize(rendered_params)
      @params = rendered_params
    end

    def hdfs(va)
      "\"hdfs://#{va[Config.hadoop.hdfs.length+1..-1]}"
    end

    def get_binding
      b = binding
      @params.each do |k, v|
        b.local_variable_set k, v
      end
      b
    end

  end

end
