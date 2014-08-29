require 'preprocessor/erlang/regular_expressions'

# Method that removes the user's comments by processing the code
# line by line and searching for comments. Returns code without
# comments.
def remove_comments(code_msg)
  codes = ''
  code_msg.each_line do |line|
    res_c = []
    line.scan('%') do
      res_c << Regexp.last_match.offset(0).first
    end
    res_s = scan_for_index_start_and_end(line, regex_verify_string_comment)
    if !res_c.empty? && !res_s.empty?
      res_c.each do |res|
        if is_not_in_string?(res, res_s)
          line.slice!(res..-1)
        end
      end
    elsif !res_c.empty?
      line.slice!(res_c[0]..-1)
    end
    codes += line.chomp + "\n"
  end
  codes
end

# Method that scans the given code for a given regular expression
# (e.g. strings) and returns an array.
# If there are matches it's empty, elsewise it contains hashes with
# start- and endpoints of the matches.
def scan_for_index_start_and_end(code, regex)
  res = []
  code.scan(regex) do
    res << {starts: Regexp.last_match.offset(0).first, ends: Regexp.last_match.offset(0).last}
  end
  res
end

# Method that gets an index and an array that contains start- and
# endpoints of strings in the code. Then proves if the given index
# lies inside one of the strings and returns a boolean.
def is_not_in_string?(index, string_indexes)
  not_in_string = true
  string_indexes.each do |pair|
    if index > pair[:starts] && index <= pair[:ends]
      not_in_string = false
    end
  end
  not_in_string
end

# Method handles the process of how the highlighting functionality
# is inserted in the code and returns the processed code.
def insert_highlighting(new_code, vars)
  string_indexes = scan_for_index_start_and_end(new_code, regex_find_strings)
  operation_indexes = scan_for_index_start_and_end(new_code, regex_find_operations)
  # Set the array of tracing variables to empty, if there only is
  # the underscore, which by default is in erlang undefined.
  vars = [] if vars.length == 1 && vars[0] == '_'

  if !vars.empty?
    vars.each do |var|
      if var != '_'
        operation_indexes += scan_for_index_start_and_end(new_code, Regexp.new("\\b#{var}\\b"))
      end
    end
    operation_indexes = operation_indexes.sort_by { |hash| hash[:starts] }
  end

  if string_indexes.empty? && !operation_indexes.empty?
    new_code = insert_prefix(new_code, operation_indexes, [])
    new_code = change_prefix_2_line_number(new_code)
  elsif !string_indexes.empty? && !operation_indexes.empty?
    new_code = insert_prefix(new_code, operation_indexes, string_indexes)
    new_code = change_prefix_2_line_number(new_code)
  end
  new_code = change_prefix_2_debug(new_code, vars) if !vars.empty?
  new_code.gsub!(regex_lineprefix, '')
  new_code
end

# Method takes code, an array of start- and endpoints of the pirate
# ship's functions as well as an array of start- and endpoints of
# the codes strings. Then inserts a prefix for later processing
# like line highlighting information.
def insert_prefix(code, operations, strings)
  if strings.empty?
    operations.reverse_each do |op|
      code.insert(op[:ends], "line#{$prefix}")
    end
  else
    operations.reverse_each do |op|
      code.insert(op[:ends], "line#{$prefix}") if is_not_in_string?(op[:starts], strings)
    end
  end
  code
end

# Takes the given code and processes the code line by line while
# searching for the beforehand inserted prefixes to exchange them
# with break-functions, functions for line highlighting and in
# case of functions of the pirates the line number.
def change_prefix_2_line_number(code)
  new_code = ''
  number = 1
  first_arrow = true
  code.each_line do |line|
    if first_arrow
      first_arrow = false if line.gsub!(regex_arrow_prefix, "-> a#{$prefix}_line(#{number}), a#{$prefix}_break(fun() ->")
    else
      line.gsub!(regex_arrow_prefix, "-> a#{$prefix}_line(#{number}), ")
    end
    first_arrow = true if line.gsub!(regex_stop_prefix, " end).line#{$prefix}")
    line.gsub!(regex_op_prefix, "(#{number}, ")
    line.gsub!(/\(\d+,\s+\)/, "(#{number})")
    new_code += line.chomp + "  % #{$prefix}_(#{number}#{$prefix}_)\n"
    number += 1
  end
  new_code
end

# Takes the code and variables to trace and scans the code line by
# line for arrows with functions and the beforehand marked variables.
# If there is a variable on the left-hand side of an arrow it inserts
# the tracing- (a.k.a. debug-)information and slices the inserted
# prefixes out of the code.
def change_prefix_2_debug(code, variables)
  array_regex_var_prefix = []
  scan_arrow = scan_for_index_start_and_end(code, regex_arrow_with_function)
  scan_stops = scan_for_index_start_and_end(code, Regexp.new("(?:\\.line#{$prefix}|;line#{$prefix})"))
  if scan_stops[0]
    puts scan_stops
  end
  debug_code = code
  variables.each_with_index do |var, index|
    array_regex_var_prefix << Regexp.new("\\b#{var}line#{$prefix}")
    debug_code = debug_code.gsub(Regexp.new("\\b#{var}line#{$prefix}\\s*="),
                                 " a#{$prefix}_debug!#{index}, a#{$prefix}_debug!#{var} =")

    my_array = scan_for_index_start_and_end(code, Regexp.new("\\b#{var}line#{$prefix}"))
    i = 0
    my_array.each do |stuff|

    end

  end

  full_debug_code = ''

=begin
  code.each_line do |line|
    array_regex_var_prefix.each_with_index do |regex, index|
      i = 0
      pos_variable = line.index(regex)
      pos_variables = scan_for_index_start_and_end(line, regex)
      puts pos_variables
      puts "full stop"
      if pos_variables[0]
        puts pos_variables[0][:starts]
      end
      pos_arrow = []
      line.scan(regex_arrow_with_function) do
        pos_arrow << Regexp.last_match.offset(0).last
      end
      if pos_variables[0] && pos_arrow[0] && pos_arrow[1] && pos_variables[0][:starts] < pos_arrow[0]

      elsif pos_variables[0] && pos_arrow[0] && pos_variables[0][:starts] < pos_arrow[0]
        line = line.insert(pos_arrow[0], " a#{$prefix}_debug!#{index}, a#{$prefix}_debug!#{variables[index]}, ")
      end
      line.gsub!(regex, variables[index])
    end
    debug_code += line
  end
=end
  puts debug_code
  debug_code
end