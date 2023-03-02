# coding: utf-8
# © 2016-2023 Resurface Labs Inc.

class HttpRule

  def initialize(verb, scope = nil, param1 = nil, param2 = nil)
    @verb = verb
    @scope = scope
    @param1 = param1
    @param2 = param2
  end

  attr_reader :verb, :scope, :param1, :param2

end
