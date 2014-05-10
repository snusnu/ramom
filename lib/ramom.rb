# encoding: utf-8

require 'concord'
require 'anima'
require 'morpher'
require 'lupo'
require 'procto'
require 'adamantium'
require 'abstract_type'
require 'inflecto'

require 'axiom'
require 'axiom-types'
require 'axiom-optimizer'
require 'axiom-do-adapter'

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

require 'ramom/relation/builder'
require 'ramom/schema/definition'
require 'ramom/schema/definition/builder'
require 'ramom/schema/definition/resolver'
require 'ramom/schema/definition/resolver/compiler'
require 'ramom/schema/mapping/natural_join'
require 'ramom/schema'
require 'ramom/mapping'
require 'ramom/reader'
