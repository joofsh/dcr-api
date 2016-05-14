require_relative '../helper'

describe Resource do
  it 'allows saving array of categories' do
    resource = Resource.spawn!
    deny resource.category
    arr = ['Cat 1', 'Cat 2', 'Cat 3']

    resource.update(category: arr)
    assert resource.reload.category.to_a.is_a?(Array)
    assert_equal arr, resource.category.to_a
  end
end
