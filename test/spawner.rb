class Sequel::Model
  def self.spawn!(attributes = {})
    record = new(attributes)
    record.send(:before_spawn)
    record.save
    record.send(:after_spawn)
    record
  end

  private

  def before_spawn
  end

  def after_spawn
  end
end


class Resource
  def before_spawn
    self.title ||= 'Dummy title'
  end
end

class User
  def before_spawn
    id = random_id
    self.first_name ||= 'John'
    self.last_name ||= 'Doe'
    self.email ||= "foo_#{random_id}@bar.com"
    self.username ||= "user_#{random_id}"
  end
end

class Tag
  def before_spawn
    self.name ||= "fun_tag_#{random_id}"
  end
end

class Question
  def before_spawn
    self.stem ||= "This is the question stem"
  end
end

class Choice
  def before_spawn
    self.stem ||= "This is the choice stem"
    self.question ||= Question.spawn!
  end
end

class Response
  def before_spawn
    self.client ||= Client.spawn!
    self.choice ||= Choice.spawn!
    self.question = self.choice.question
  end
end
