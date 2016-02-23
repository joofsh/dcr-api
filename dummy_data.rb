def build_dummy_data
  User.create(first_name: 'JD', last_name: 'Pagano', username: 'joofsh_admin', email: 'jonathanpagano+1@gmail.com', role: 'admin', password: 'foobar')

  a = Advocate.create(first_name: 'JD', last_name: 'Pagano', username: 'joofsh', email: 'jonathanpagano@gmail.com', password: 'foobar')
  5.times do |i|
    Client.create(first_name: 'John', last_name: 'Doe', birthdate: (Date.today - i), advocate_id: a.id)
  end

  tags = [
    Tag.create(name: 'hiv-positive'),
    Tag.create(name: 'narcotic-user'),
    Tag.create(name: 'homeless'),
  ]

  cl = Client.first
  cl.add_tag tags[0]
  cl.add_tag tags[1]

  10.times do |i|
    r = Resource.create(title: "Dummy Resource ##{i}", url: 'http://google.com')

    r.add_tag tags[i % 3]
  end

  q3 = Question.create(stem: 'Do you have a stable home residence?', order: 3)
  Choice.create(stem: 'Yes', question: q3)
  Choice.create(stem: 'No', question: q3, tag: tags[2])

  q2 = Question.create(stem: 'Are you actively taking narcotic?', order: 2)
  Choice.create(stem: 'Yes', question: q2, next_question: q3, tag: tags[1])
  Choice.create(stem: 'No', question: q2, next_question: q3)

  q1 = Question.create(stem: 'Are you HIV positive?', order: 1)
  Choice.create(stem: 'Yes', question: q1, next_question: q2, tag: tags[0])
  Choice.create(stem: 'No', question: q1, next_question: q2)

end
