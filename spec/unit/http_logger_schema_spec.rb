# coding: utf-8
# © 2016-2020 Resurface Labs Inc.

require 'resurfaceio/all'
require_relative 'helper'

describe HttpLogger do

  it 'loads default schema' do
    queue = []
    logger = HttpLogger.new(queue: queue)
    expect(logger.schema).to be nil
  end

  it 'loads schema' do
    myschema = 'type Foo { bar: String }'

    queue = []
    logger = HttpLogger.new(queue: queue, schema: myschema)
    expect(logger.schema.equal?(myschema)).to be true

    expect(queue.length).to eql(1)
    msg = queue[0]
    expect(parseable?(msg)).to be true
    expect(msg.include?("[\"graphql_schema\",\"#{myschema}\"]")).to be true
  end

  it 'loads schema from file' do
    myschema = 'type Query { hello: String }'

    queue = []
    logger = HttpLogger.new(queue: queue, schema: 'file://./spec/schema1.txt')
    expect(logger.schema.include?(myschema)).to be true

    expect(queue.length).to eql(1)
    msg = queue[0]
    expect(parseable?(msg)).to be true
    expect(msg.include?("[\"graphql_schema\",\"#{myschema}\"]")).to be true
  end

  it 'raises expected errors' do
    begin
      queue = []
      new HttpLogger.new(queue: queue, schema: "file://~/bleepblorpbleepblorp12345")
      expect(false).to be true
    rescue RuntimeError => e
      expect(e.message).to eql("Failed to load schema: ~/bleepblorpbleepblorp12345")
    end
  end

end
