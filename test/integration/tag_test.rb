require_relative '../helper'

describe 'Tags' do
  before do
    @tag = Tag.spawn! name: 'sad_tag'
    3.times { Tag.spawn! }
  end

  describe 'GET /tags' do
    it 'returns tags' do
      get user_url('/tags')

      tag = body[:tags].first

      assert_equal 200, status
      assert_equal 4, body[:count]
      assert_equal @tag.id, tag[:id]
      assert_equal @tag.name, tag[:name]
    end
  end
end
