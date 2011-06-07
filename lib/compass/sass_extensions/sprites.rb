require 'digest/md5'
require 'compass/sprite_importer'


module Compass
  module SassExtensions
    module Sprites
    end
  end
end

#modules
require 'compass/sass_extensions/sprites/sprite'
require 'compass/sass_extensions/sprites/processing'
require 'compass/sass_extensions/sprites/image_helper'
#classes
require 'compass/sass_extensions/sprites/sprite_map'
require 'compass/sass_extensions/sprites/image'
require 'compass/sass_extensions/sprites/row_fitter'
require 'compass/sass_extensions/sprites/image_row'
require 'compass/sass_extensions/sprites/engines'