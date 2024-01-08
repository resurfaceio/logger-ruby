# coding: utf-8
# © 2016-2024 Graylog, Inc.

require 'resurfaceio/all'
require_relative 'helper'

describe HttpLogger do

  it 'creates instance' do
    logger = HttpLogger.new
    expect(logger.nil?).to be false
    expect(logger.agent).to eql(HttpLogger::AGENT)
    expect(logger.enableable?).to be false
    expect(logger.enabled?).to be false
    expect(logger.queue).to be nil
    expect(logger.url).to be nil
  end

  it 'creates multiple instances' do
    url1 = 'https://resurface.io'
    url2 = 'https://whatever.com'
    logger1 = HttpLogger.new(url1)
    logger2 = HttpLogger.new(url: url2)
    logger3 = HttpLogger.new(url: DEMO_URL)

    expect(logger1.agent).to eql(HttpLogger::AGENT)
    expect(logger1.enableable?).to be true
    expect(logger1.enabled?).to be true
    expect(logger1.url).to eql(url1)
    expect(logger2.agent).to eql(HttpLogger::AGENT)
    expect(logger2.enableable?).to be true
    expect(logger2.enabled?).to be true
    expect(logger2.url).to eql(url2)
    expect(logger3.agent).to eql(HttpLogger::AGENT)
    expect(logger3.enableable?).to be true
    expect(logger3.enabled?).to be true
    expect(logger3.url).to eql(DEMO_URL)

    UsageLoggers.disable
    expect(UsageLoggers.enabled?).to be false
    expect(logger1.enabled?).to be false
    expect(logger2.enabled?).to be false
    expect(logger3.enabled?).to be false
    UsageLoggers.enable
    expect(UsageLoggers.enabled?).to be true
    expect(logger1.enabled?).to be true
    expect(logger2.enabled?).to be true
    expect(logger3.enabled?).to be true
  end

  it 'has valid agent' do
    agent = HttpLogger::AGENT
    expect(agent).not_to be nil
    expect(agent).to be_kind_of String
    expect(agent.length).to be > 0
    expect(agent.end_with?('.rb')).to be true
    expect(agent.include?('\\')).to be false
    expect(agent.include?('\"')).to be false
    expect(agent.include?('\'')).to be false
    expect(HttpLogger.new.agent).to eql(agent)
  end

  it 'silently ignores unexpected option types' do
    logger = HttpLogger.new([])
    expect(logger.enableable?).to be false
    expect(logger.enabled?).to be false
    expect(logger.queue).to be(nil)
    expect(logger.url).to be nil

    logger = HttpLogger.new(url: true)
    expect(logger.enableable?).to be false
    expect(logger.enabled?).to be false
    expect(logger.queue).to be(nil)
    expect(logger.url).to be nil

    logger = HttpLogger.new(url: [])
    expect(logger.enableable?).to be false
    expect(logger.enabled?).to be false
    expect(logger.queue).to be(nil)
    expect(logger.url).to be nil

    logger = HttpLogger.new(url: 23)
    expect(logger.enableable?).to be false
    expect(logger.enabled?).to be false
    expect(logger.queue).to be(nil)
    expect(logger.url).to be nil
  end

end
