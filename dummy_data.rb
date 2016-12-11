def build_dummy_data
  Advocate.create(first_name: 'JD', last_name: 'Pagano', username: 'joofsh_admin', email: 'jonathanpagano+1@gmail.com', role: 'admin', password: 'foobar')

  a = Advocate.create(first_name: 'JD', last_name: 'Pagano', username: 'joofsh', email: 'jonathanpagano@gmail.com', password: 'foobar')
  5.times do |i|
    Client.create(first_name: 'John', last_name: 'Doe', birthdate: (Date.today - i), advocate_id: a.id)
  end

  tags = [
    Tag.create(name: 'hiv-positive', weight: 40),
    Tag.create(name: 'narcotic-user', weight: 60),
    Tag.create(name: 'homeless', weight: 80),
    Tag.create(name: 'shelter', type: 'Service')
  ]

  cl = Client.first
  cl.add_tag tags[0]
  cl.add_tag tags[1]

  10.times do |i|
    r = Resource.create(title: "Dummy Resource ##{i}",
                        description: "New amazing awesome resource just for you!\n Second line",
                        category: ['Physical Health'],
                        url: 'http://google.com',
                        published: true)

    r.add_tag tags[i % 4]
    r.add_tag tags[i % 3] rescue nil
  end

  3.times do |i|
    guest = Guest.create
    Tag.each do |tag|
      guest.add_tag(tag)
    end
  end

  q3 = Question.create(stem: 'Do you have a stable home residence?', order: 3)
  Choice.create(stem: 'Yes', question: q3)
  ch = Choice.create(stem: 'No', question: q3)
  ch.update(tag_pks: [tags[2].id])

  q2 = Question.create(stem: 'Are you actively taking narcotic?', order: 2)
  ch = Choice.create(stem: 'Yes', question: q2, next_question: q3)
  ch.update(tag_pks: [tags[1].id])
  Choice.create(stem: 'No', question: q2, next_question: q3)

  q1 = Question.create(stem: 'Are you HIV positive?', order: 1)
  ch = Choice.create(stem: 'Yes', question: q1, next_question: q2)
  ch.update(tag_pks: [tags[0].id])
  Choice.create(stem: 'No', question: q1, next_question: q2)

end
