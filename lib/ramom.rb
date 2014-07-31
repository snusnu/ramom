# encoding: utf-8

require 'concord'
require 'anima'
require 'lupo'
require 'procto'
require 'adamantium'
require 'abstract_type'

require 'axiom'
require 'axiom-optimizer'

# Relational Algebra meets Object Mapping
module Ramom

  # Represent an undefined argument
  Undefined = Module.new.freeze

  # An empty hash useful for (default} parameters
  EMPTY_HASH = {}.freeze

  # An empty frozen hash of sets needed for FK constraints
  FK_C_HASH = Hash.new { |h, k| h[k] = Set.new }.freeze

  # An empty frozen string
  EMPTY_STRING = ''.freeze

  # An empty frozen array
  EMPTY_ARRAY = [].freeze

  def self.command(*args)
    Command.registrar(*args)
  end

  def self.query(*args)
    Query.registrar(*args)
  end

end # Ramom

require 'ramom/version'
require 'ramom/relation/builder'
require 'ramom/schema/fk_constraint'
require 'ramom/schema/fk_wrapper'
require 'ramom/schema/definition'
require 'ramom/schema/definition/context'
require 'ramom/schema/definition/compiler'
require 'ramom/naming/natural_join'
require 'ramom/schema/builder'
require 'ramom/schema'
require 'ramom/reader'
require 'ramom/writer'
require 'ramom/aggregate'
require 'ramom/operation/registry'
require 'ramom/operation/registrar'
require 'ramom/operation/result'
require 'ramom/operation/environment'
require 'ramom/operation'
require 'ramom/command'
require 'ramom/query'
require 'ramom/database'
require 'ramom/facade'
