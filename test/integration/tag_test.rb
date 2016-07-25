require_relative '../helper'

describe 'Tags' do
  before do
    @advocate = Advocate.spawn!
    @tag = Tag.spawn! name: 'sad_tag'
    3.times { Tag.spawn! }
  end

  describe 'GET /tags' do
    it 'requires auth' do
      get '/tags'
      assert_equal 403, status
    end

    it 'returns tags' do
      get user_url('/tags')

      tag = body[:tags].first

      assert_equal 200, status
      assert_equal 4, body[:count]
      assert_equal @tag.id, tag[:id]
      assert_equal @tag.name, tag[:name]
      deny tag.key? :choices
      deny tag.key? :resources
    end

    it 'orders them by category and order' do
      Tag.each(&:destroy)
      q1 = Tag.spawn!(type: 'Descriptor', weight: 2)
      q2 = Tag.spawn!(type: 'Service', weight: 1)
      q3 = Tag.spawn!(type: 'Descriptor', weight: 1)
      q4 = Tag.spawn!(type: 'Service', weight: 2)

      get user_url('/tags')
      assert_equal 200, status
      tag_ids = body[:tags].map { |t| t[:id] }
      assert_equal [q4.id, q2.id, q1.id, q3.id], tag_ids
    end

    it 'provides full details' do
      choice = Choice.spawn!
      choice.add_tag(@tag)

      get user_url('/tags?details=true')

      tag = body[:tags].first

      assert_equal 200, status
      assert tag.key? :choices
      assert tag.key? :resources
    end
  end

  describe 'POST /tags' do
    before do
      @attrs = {
        name: 'foo',
        weight: 10,
        type: 'Service'
      }
    end

    it 'creates a new tag' do
      post user_url('/tags', @advocate), { tag: @attrs }

      assert_equal 201, status
      assert_equal @attrs[:name], body[:name]
      assert_equal @attrs[:weight], body[:weight]
      assert_equal @attrs[:type], body[:type]
    end
  end

  describe 'PUT /tags/:id' do
    before do
      @attrs = {
        name: 'foo',
        weight: 10,
        type: 'Service'
      }
    end

    it 'creates a new tag' do
      deny @tag.name == @attrs[:name]

      put user_url("/tags/#{@tag.id}", @advocate), { tag: @attrs }

      assert_equal 200, status
      assert_equal @attrs[:name], body[:name]
    end
  end

  describe 'DELETE /tags/:id' do
    it 'deletes' do
      assert Tag[@tag.id]
      delete user_url("/tags/#{@tag.id}")
      deny Tag[@tag.id]
    end
  end
end
