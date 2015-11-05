require 'rgl/adjacency'
require 'rgl/topsort'

class JobEngine

  def initialize(user_id, datastore)
    @user_id = user_id
    @datastore = datastore
  end


  def submit(boxes, conns)
    job_id = SecureRandom.uuid
    job = Job.new id: job_id,
                  user_id: @user_id

    outdir = job.outdir
    output_prefix = @datastore.apath outdir
    @datastore.mkdir! outdir

    preset = {}
    preset['STREAMING_JAR'] = Config.dir_lib Config.lib.streaming
    preset['HADOOP_BIN'] = Config.hadoop.bin

    env = {}
    env['HADOOP_USER_NAME'] = Config.hadoop.username

    units = {}

    #Fill the blank output param
    boxes.each do |k, v|
      tool = Tool.find v['tool_id']
      tool.params.each do |e|
        if e['type'] == 'tmp'
          boxes[k]['values'][e['name']] = File.join '.tmp', SecureRandom.uuid
        end

        v['values'].each do |ka, va|
          if e['name'] == ka
            if e['type'] == 'output'
              if va.blank?
                boxes[k]['values'][ka] = File.join '.tmp', SecureRandom.uuid
              else
                boxes[k]['values'][ka] = File.join output_prefix, va
              end
            end
          end
        end
      end
    end

    #Copy output param to input param for connected tools
    dg=RGL::DirectedAdjacencyGraph.new
    conns.each do |e|
      dg.add_edge e['sourceId'], e['targetId']

      if boxes[e['targetId']]['values'][e['targetParamName']].blank?
        boxes[e['targetId']]['values'][e['targetParamName']] = boxes[e['sourceId']]['values'][e['sourceParamName']]
      else
        boxes[e['targetId']]['values'][e['targetParamName']] += ",#{boxes[e['sourceId']]['values'][e['sourceParamName']]}"
      end
    end

    #Generate commands
    boxes.each do |k, v|
      tool = Tool.find v['tool_id']
      command = tool.command.dup

      preset.merge(v['values']).each do |ka, va|
        if va.kind_of? Array
          separator = ''
          tool.params.each do |p|
            separator = p['separator'] if p['name'] == ka
          end
          va = va.join separator
        end

        tool.params.each do |e|
          if e['name'] == ka
            case e['type']
              when 'input'
                va = va.split ','
                va = va.collect do |ev|
                  if ev.start_with? '@'
                    username = ev[1, ev.index(':')-1]
                    user = User.find_by username: username
                    ud = Datastore.new user.id, Config.nfs
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
                va = @datastore.apath va
            end

          end
        end

        command.gsub! /\#{#{ka}}/, va.to_s
      end

      units[k] = {id: SecureRandom.uuid, tool_id: tool.id, params: tool.params, command: command, wd: tool.dirpath, env: env}
    end

    ordere_units = dg.topsort_iterator.to_a

    if ordere_units.length == 0
      ordere_units = units.values
    else
      ordere_units = ordere_units.collect do |e|
        units[e]
      end
    end

    ordere_units.each_with_index do |u, idx|
      ju = JobUnit.new u
      ju.job_id = job_id
      ju.idx = idx
      ju.save
    end

    job.save
    RMQ.publish 'jobs', {id: job_id, units: ordere_units}
  end

end
