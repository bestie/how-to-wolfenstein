$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))

require "game"
require "map"
require "player"
require "vector"
require "mutable_vector"
require "ansi"
require "ansi_renderer"
require "ray_tracer"

define_method("π") { Math::PI }
