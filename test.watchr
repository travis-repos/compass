watch('test/(.*)_test\.rb') { |m| test(m[0]) }
watch('lib/compass/sass_extensions/sprites/image_group.rb') { test('test/units/sprites/image_group_test.rb') }
watch('lib/compass/sass_extensions/sprites/row_fitter.rb') { test('test/units/sprites/row_fitter_test.rb') }

def test(file = nil)
  system %{ruby -I"lib:test" #{file}}.tap { |o| puts o }
end
