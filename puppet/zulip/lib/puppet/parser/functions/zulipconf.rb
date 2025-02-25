module Puppet::Parser::Functions
  newfunction(:zulipconf, :type => :rvalue, :arity => -2) do |args|
    default = args.pop
    joined = args.join(" ")
    zulip_conf_path = lookupvar("zulip_conf_path")
    output = `/usr/bin/crudini --get #{zulip_conf_path} #{joined} 2>&1`; result = $?.success?
    if result
      if [true, false].include? default
        # If the default is a bool, coerce into a bool.  This list is also
        # maintained in scripts/lib/zulip_tools.py
        ['1','y','t','true','yes','enable','enabled'].include? output.strip.downcase
      else
        output.strip
      end
    else
      default
    end
  end

  newfunction(:zulipconf_keys, :type => :rvalue, :arity => 1) do |args|
    zulip_conf_path = lookupvar("zulip_conf_path")
    output = `/usr/bin/crudini --get #{zulip_conf_path} #{args[0]} 2>&1`; result = $?.success?
    if result
      return output.lines.map { |l| l.strip }
    else
      return []
    end
  end

  newfunction(:zulipconf_nagios_hosts, :type => :rvalue, :arity => 0) do |args|
    section = "nagios"
    prefix = "hosts_"
    zulip_conf_path = lookupvar("zulip_conf_path")
    keys = `/usr/bin/crudini --get #{zulip_conf_path} #{section} 2>&1`; result = $?.success?
    if result
      filtered_keys = keys.lines.map { |l| l.strip }.select { |l| l.start_with?(prefix) }
      all_values = []
      filtered_keys.each do |key|
        values = `/usr/bin/crudini --get #{zulip_conf_path} #{section} #{key} 2>&1`; result = $?.success?
        if result
          all_values += values.strip.split(/,\s*/)
        end
      end
      return all_values
    else
      return []
    end
  end
end
