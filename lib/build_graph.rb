require_relative '../app'

# Build .gv file necessary to render graph using graphViz
#
# File will have format:
#
# digraph Question
# {
# Q1[label = "Do you have a stable home residence?"];
# Q2[label = "Are you actively taking narcotic?"];
# Q3[label = "Are you HIV positive?"];
# C1[label = "Yes"];
# C2[label = "No"];
# C3[label = "Yes"];
# C4[label = "No"];
# C5[label = "Yes"];
# C6[label = "No"];
# Q1 -> C1
# C1 -> Q
# Q1 -> C2
# C2 -> Q
# Q2 -> C3
# C3 -> Q1
# Q2 -> C4
# C4 -> Q1
# Q3 -> C5
# C5 -> Q2
# Q3 -> C6
# C6 -> Q2
# }

def build_graph
  f = File.new('question_visualization.gv', 'w')
  f.puts 'digraph Question'
  f.puts '{'
  Question.each do |q|
    f.puts "Q#{q.id}[label = \"#{q.stem}\"];"
  end
  Choice.each do |c|
    f.puts "C#{c.id}[label = \"#{c.stem}\"];"
  end

  f.puts ''

  Choice.each do |c|
    f.puts "Q#{c.question_id} -> C#{c.id}"
    f.puts "C#{c.id} -> Q#{c.next_question_id}"
  end

  f.puts '}'
end
