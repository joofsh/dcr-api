require 'digest/md5'
require 'securerandom'

class User < Sequel::Model
  plugin :nested_attributes
  include Shield::Model

  hidden_fields :crypted_password
  blacklisted_fields :crypted_password
  presented_methods :name, :image_url, :mailing_address, :home_address, :staff, :guest

  plugin :single_table_inheritance,
    :role,
    model_map: {
      'guest' => :Guest,
      'client' => :Client,
      'advocate' => :Advocate,
      'admin' => :Admin
    }

  one_to_many :resources
  one_to_many :responses, order: Sequel.asc(:created_at)
  many_to_many :tags, order: Sequel.desc(:weight)
  many_to_one :mailing_address, class: :Address
  many_to_one :home_address, class: :Address

  nested_attributes :mailing_address, :home_address

  add_association_dependencies mailing_address: :destroy,
                               home_address:    :destroy,
                               responses:       :destroy

  def self.fetch(identifier)
    self[identifier.to_i] ||
      self.where(email: identifier).first ||
      self.where(username: identifier).first
  end

  def questions_dataset
    Question.ordered
  end

  # TODO: Refactor this. Needs to become a lot more sophisticated
  # and faster.
  def resource_map
    @resource_map ||= begin
      tags_dataset.service.order_by_weight.reduce({}) do |hash, service_tag|
        hash[service_tag.name.to_sym] =
          Resource.sorted_by_descriptor_weight(service_tag).all
        hash
      end
    end
  end

  # Master list of all resources. Used for demo purposes
  def self.master_resource_map
    @master_resource_map ||= begin
      Tag.service.order_by_weight.reduce({}) do |hash, service_tag|
        hash[service_tag.name.to_sym] =
          Resource.sorted_by_descriptor_weight(service_tag).all
        hash
      end
    end
  end

  def users_dataset
    raise 'Must be defined in subclasses'
  end

  def staff?
    false
  end

  def guest?
    false
  end

  # presented version
  def staff
    staff?
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
    self.role ||= 'guest'

    unless username
      if last_name
        self.username = "#{last_name}_#{(birthdate || Time.now).to_s}"
      else
        self.username = SecureRandom.hex(16)
      end
    end

  end

  def validate
    super

    validates_presence [:role, :username] # all roles

    if role == 'client'
      validates_presence [:first_name, :last_name]
    elsif role == 'admin' || role == 'advocate'
      validates_presence [:first_name, :last_name, :crypted_password]
    end

    validates_unique :username, :email
  end
end
