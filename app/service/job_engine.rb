require 'rgl/adjacency'
require 'rgl/topsort'

class JobEngine

  def initialize(user_id, datastore)
    @user_id = user_id
    @datastore = datastore
  end


  def submit(boxes, conns)
    job_id = SecureRandom.uuid
    job = Job.new id: job_id, user_id: @user_id

    result = {
        success: true,
        job_id: job_id,
        errors: []
    }

    outdir = job.outdir
    @datastore.mkdir! outdir

    preset = {}
    preset['STREAMING_JAR'] = Config.dir_lib Config.lib.streaming
    preset['QOMO_COMMON'] = Config.dir_lib Config.lib.common
    preset['HADOOP_BIN'] = Config.hadoop.bin
    preset['SPARK_SUBMIT'] = Config.spark.submit
    preset['SPARK_MASTER'] = Config.spark.master

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

      preset.merge(pvalues).each do |ka, va|
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

            when 'output'
              va = @datastore.apath va
            when 'tmp'
              va = @datastore.apath "#{outdir}/.tmp/#{unit_id}"
            else
              # No-op
          end
        end

        inject_param command, ka, va
      end

      units[k] = {id: unit_id, tool_id: tool.id, params: tool.params, command: command, wd: tool.dirpath, env: env}
    end

    return result unless result[:success]

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
      RMQ.publish 'jobs', {id: job_id, units: ordere_units}
    end

    result
  end


  def inject_param(command, ka, va)
    va = va.to_s
    if ka.start_with? 'hdfs:'
      va = "hdfs:#{va[Config.hadoop.hdfs.length..-1]}"
    end
    command.gsub! /\#{#{ka}}/, va
  end

end
