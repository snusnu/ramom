# encoding: utf-8

require 'anima'
require 'lupo'
require 'procto'
require 'morpher'

# Relational Algebra meets Object Mapping
module Ramom

  # Represent an undefined argument
  Undefined = Class.new.freeze

  # An empty hash useful for (default} parameters
  EMPTY_HASH = {}.freeze

  # An empty frozen string
  EMPTY_STRING = ''.freeze

  # An empty frozen array
  EMPTY_ARRAY = [].freeze

end # Ramom

require 'ramom/version'
require 'ramom/schema'
require 'ramom/entity'
require 'ramom/entity/definition'
require 'ramom/entity/definition/registry'
require 'ramom/entity/definition/attribute'
require 'ramom/entity/definition/attribute/primitive'
require 'ramom/entity/definition/attribute/embedded'
require 'ramom/entity/morpher/builder/attribute'
require 'ramom/entity/morpher/builder/attribute/primitive'
require 'ramom/entity/morpher/builder/attribute/embedded'
require 'ramom/entity/morpher/builder/entity'
require 'ramom/entity/morpher'
require 'ramom/entity/morpher/registry'
require 'ramom/entity/model/registry'
require 'ramom/entity/model/builder'
require 'ramom/entity/model/builder/anima'
require 'ramom/entity/mapper'
require 'ramom/entity/environment'
require 'ramom/entity/registry'
