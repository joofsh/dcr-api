require 'digest/md5'

class User < Sequel::Model
  plugin :nested_attributes
  include Shield::Model

  hidden_fields :crypted_password
  blacklisted_fields :crypted_password
  presented_methods :name, :image_url, :mailing_address, :home_address, :staff

  plugin :single_table_inheritance,
    :role,
    model_map: {
      'client' => :Client,
      'advocate' => :Advocate,
      'admin' => :Admin
    }

  many_to_many :tags, order: Sequel.desc(:weight)
  many_to_one :mailing_address, class: :Address
  many_to_one :home_address, class: :Address

  nested_attributes :mailing_address, :home_address

  add_association_dependencies mailing_address: :destroy,
                               home_address:    :destroy

  def self.fetch(identifier)
    self[identifier.to_i] ||
      self.where(email: identifier).first ||
      self.where(username: identifier).first
  end

  def users_dataset
    raise 'Must be defined in subclasses'
  end

  def is_staff?
    false
  end

  def staff
    is_staff?
  end

  def name
    "#{first_name} #{last_name}"
  end

  def image_url
    return nil unless email

    hash = Digest::MD5.hexdigest email.downcase
    "https://www.gravatar.com/avatar/#{hash}"
  end

  def before_validation
    self.username ||= "#{last_name}_#{(birthdate || Time.now).to_s}"
    self.role ||= 'client'
  end

  def validate
    super

    validates_presence [:role, :username, :first_name, :last_name]
    validates_unique :username, :email
  end

  def extend_present
    {
      tags: tags.map(&:name)
    }
  end

end
