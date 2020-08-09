$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))

require "game"
require "map"
require "player"
require "vector"

define_method("π") { Math::PI }
