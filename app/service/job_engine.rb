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
    tmpdir = job.tmpdir
    @datastore.mkdir! outdir
    @datastore.mkdir! tmpdir

    env = {}
    env['HADOOP_USER_NAME'] = Config.hadoop.username

    units = {}

    #Fill the blank output param
    boxes.each do |k, v|
      tool = Tool.find v['tool_id']
      tool.params.each do |e|
        if e['type'] == 'tmp'
          boxes[k]['values'][e['name']] = File.join tmpdir, SecureRandom.uuid
        end

        v['values'].each do |ka, va|
          if e['name'] == ka
            if e['type'] == 'output'
              if va.blank?
                boxes[k]['values'][ka] = File.join tmpdir, SecureRandom.uuid
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
    boxes.each do |bid, _|
      dg.add_vertex bid
    end
    conns.each do |e|
      dg.add_edge e['sourceId'], e['targetId']

      if boxes[e['targetId']]['values'][e['targetParamName']].blank?
        boxes[e['targetId']]['values'][e['targetParamName']] = boxes[e['sourceId']]['values'][e['sourceParamName']]
      else
        boxes[e['targetId']]['values'][e['targetParamName']] += ",#{boxes[e['sourceId']]['values'][e['sourceParamName']]}"
      end
    end

    # Generate commands
    # TODO rename variable `k, v`
    boxes.each do |k, v|
      tool = Tool.find v['tool_id']
      unit_id = SecureRandom.uuid
      command = tool.command.dup

      pvalues = v['values']

      # Validate all params are set correctly (not null, etc.)
      rendered_params = tool.params.collect do |param_def|
        param_name = param_def['name']
        param_value = pvalues[param_name]
        if param_value.blank?
          unless param_def['nullable'] or param_def['type'] == 'output'
            result[:success] = false
            result[:errors] << {box_id: k, param: param_def['label'], msg: 'need value to be set'}
          end
          param_value = nil
        else
          separator = param_def['separator'] || ','
          if param_def['multiple'] and param_value.kind_of?(Array)
            param_value = param_value.join(separator)
          end

          case param_def['type']
            when 'input'
              param_value = param_value.split(',').collect do |path|
                if path.start_with? '@'
                  username = path[1, path.index(':')-1]
                  user = User.find_by username: username
                  # TODO: Remove this ugly implementation
                  ud = Datastore.new user.id, Config.dir_users
                  path = ud.apath path[path.index(':')+1 .. -1]
                else
                  path = @datastore.apath path
                end
                path
              end.join(',')

            when 'output'
              param_value = @datastore.apath param_value
            when 'tmp'
              param_value = @datastore.apath "#{tmpdir}/#{unit_id}"
            else
              # No-op
          end
        end
        [param_name, param_value]
      end

      rendered_params = Hash[*rendered_params.flatten]

      command = inject_param command, rendered_params
      units[k] = {id: unit_id, tool_id: tool.id, params: tool.params, command: command, wd: tool.dirpath, env: env}
    end

    unless result[:success]
      @datastore.delete! outdir
      return result
    end

    ordere_units = dg.topsort_iterator.to_a

    ordere_units = ordere_units.collect do |e|
      units[e]
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
    # Escape chars
    command = command.gsub /"/, '\"'
    eval "\"#{command}\"", CommandBinding.new(rendered_params).get_binding
  end


  class CommandBinding

    STREAMING_JAR = Config.dir_lib Config.lib.streaming
    QOMO_COMMON = Config.dir_lib Config.lib.common
    HADOOP_BIN = Config.hadoop.bin
    SPARK_SUBMIT = Config.spark.submit
    SPARK_MASTER = Config.spark.master

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
