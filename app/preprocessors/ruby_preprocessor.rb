# -*- encoding : utf-8 -*-
class RubyPreprocessor < BasePreprocessor

  # A constant that stores the ship-logic for Ruby that's put in the code of the user to get the ship moving.
  # Looks like this:
  #  def move
  #    puts "move"
  #  end
  #  def turnRight
  #    puts "turnRight"
  #  end
  #  def turnLeft
  #    puts "turnLeft"
  #  end
  #  def addBuoy
  #    puts "addBuoy"
  #  end
  #  def line(i)
  #    puts "\nline?#{i}"
  #  end

  def initialize(attribut)
    super(attribut)
  end

  def process_code(code_msg)
    i=0
    codes = ''
    code_msg << "\n"
    code_msg.each_line do |s|
      codes += s + "line(#{i})\n"
      i += 1
    end
    insert_logic + codes + "\n"
  end

  def debug_code(code_msg, vars)
    i=0
    code = ''
    code_msg << "\n"
    code_msg.each_line do |s|
      code += s + "line(#{i})\n" #TO DO: add the json object for tracing variables
      i += 1
    end
    LANGUAGE_LOGIC + SHIP_LOGIC + code + "\n"
  end

  def insert_logic
    "STDOUT.sync = true\n" +
        "def move\n" +
        "  puts \"#{$prefix}move\"\n" +
        "end\n" +
        "def turnRight\n" +
        "  puts \"#{$prefix}turnRight\"\n" +
        "end\n" +
        "def turnLeft\n" +
        "  puts \"#{$prefix}turnLeft\"\n" +
        "end\n" +
        "def put\n" +
        "  puts \"#{$prefix}put\"\n" +
        "end\n" +
        "def line(i)\n" +
        "  puts \"\\n#{$prefix}line!\#{i}\"\n" +
        "end\n" +
        "def look(dir)\n" +
        "  case dir\n" +
        "    when 'right' then puts \"#{$prefix}?_look_right\"\n" +
        "    when 'left' then puts \"#{$prefix}?_look_left\"\n" +
        "    when 'here' then puts \"#{$prefix}?_look_here\"\n" +
        "    when 'back' then puts \"#{$prefix}?_look_back\"\n" +
        "    when 'front' then puts \"#{$prefix}?_look_front\"\n"+
        "  end\n" +
        "  ret = gets\n" +
        "  ret\n" +
        "end\n\n"

  end

end
