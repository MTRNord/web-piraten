module ControlSimulation

  def exit_simulation!(packet, line='')
    send_packet(packet)
    packet[:operations] ||= []
    packet[:operations] << {:name => 'exit'}
    if line != ''
      print!(packet, :error, line) #add errormessages
    else
      print!(packet, :log, 'Ausführung beendet!') #add endmessage
    end
    send_packet(packet)
    connection_store[:is_simulation_done] = true
  end

  def print!(packet, type, line)
    remove_prefix! line
    line = CGI::escapeHTML(line)
    packet[:messages] ||= []
    packet[:messages] << {:type => type, :message => line}
  end

  def debug!(packet, tracing_vars, old_allocations, name_index, value)
    name = tracing_vars[name_index].chomp
    remove_prefix! name
    remove_prefix! value

    old_allocations[name] ||= {}
    if old_allocations[name] != value
      old_allocations[name] = value
      packet[:allocations] ||= {}
      packet[:allocations][name] = value
    end
  end
end