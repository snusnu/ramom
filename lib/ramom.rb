# encoding: utf-8

require 'concord'
require 'anima'
require 'lupo'
require 'procto'
require 'adamantium'
require 'abstract_type'

require 'axiom'
require 'axiom-types'
require 'axiom-optimizer'
require 'axiom-do-adapter'

# Relational Algebra meets Object Mapping
module Ramom

  # Represent an undefined argument
  Undefined = Module.new.freeze

  # An empty hash useful for (default} parameters
  EMPTY_HASH = {}.freeze

  # An empty frozen hash of arrays needed for FK constraints
  FK_C_HASH = Hash.new { |h, k| h[k] = [] }.freeze

  # An empty frozen string
  EMPTY_STRING = ''.freeze

  # An empty frozen array
  EMPTY_ARRAY = [].freeze

end # Ramom

require 'ramom/version'
require 'ramom/relation/builder'
require 'ramom/schema/definition'
require 'ramom/schema/definition/fk_constraint'
require 'ramom/schema/definition/builder'
require 'ramom/schema/definition/resolver'
require 'ramom/schema/definition/resolver/compiler'
require 'ramom/schema/mapping/natural_join'
require 'ramom/schema'
require 'ramom/mapping'
require 'ramom/reader'
