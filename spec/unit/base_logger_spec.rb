# coding: utf-8
# © 2016-2017 Resurface Labs LLC

require 'resurfaceio/all'
require_relative 'helper'

describe BaseLogger do

  it 'uses module namespace' do
    expect(BaseLogger.class.equal?(Resurfaceio::BaseLogger.class)).to be true
    expect(Resurfaceio::BaseLogger.version_lookup).to eql(BaseLogger.version_lookup)
  end

  it 'manages multiple instances' do
    agent1 = 'agent1'
    agent2 = 'AGENT2'
    agent3 = 'aGeNt3'
    url1 = 'http://resurface.io'
    url2 = 'http://whatever.com'
    logger1 = BaseLogger.new(agent1, url1)
    logger2 = BaseLogger.new(agent2, url: url2)
    logger3 = BaseLogger.new(agent3, url: 'DEMO')

    expect(logger1.agent).to eql(agent1)
    expect(logger1.enabled?).to be true
    expect(logger1.url).to eql(url1)
    expect(logger2.agent).to eql(agent2)
    expect(logger2.enabled?).to be true
    expect(logger2.url).to eql(url2)
    expect(logger3.agent).to eql(agent3)
    expect(logger3.enabled?).to be true
    expect(logger3.url).to eql(UsageLoggers.url_for_demo)

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

  it 'provides valid version' do
    version = BaseLogger.version_lookup
    expect(version).not_to be nil
    expect(version).to be_kind_of String
    expect(version.length).to be > 0
    expect(version.start_with?('1.6.')).to be true
    expect(version.include?('\\')).to be false
    expect(version.include?('\"')).to be false
    expect(version.include?('\'')).to be false
    expect(BaseLogger.new(MOCK_AGENT).version).to eql(BaseLogger.version_lookup)
  end

  it 'performs enabling when expected' do
    logger = BaseLogger.new(MOCK_AGENT, url: 'DEMO', enabled: false)
    expect(logger.enabled?).to be false
    expect(logger.url).to eql(UsageLoggers.url_for_demo)
    logger.enable
    expect(logger.enabled?).to be true

    logger = BaseLogger.new(MOCK_AGENT, url: UsageLoggers.url_for_demo, enabled: true)
    expect(logger.enabled?).to be true
    expect(logger.url).to eql(UsageLoggers.url_for_demo)
    logger.enable.disable.enable.disable.disable.disable.enable
    expect(logger.enabled?).to be true

    logger = BaseLogger.new(MOCK_AGENT, queue: [], enabled: false)
    expect(logger.enabled?).to be false
    expect(logger.url).to be nil
    logger.enable.disable.enable
    expect(logger.enabled?).to be true
  end

  it 'skips enabling for invalid urls' do
    URLS_INVALID.each do |url|
      logger = BaseLogger.new(MOCK_AGENT, url: url)
      expect(logger.enabled?).to be false
      expect(logger.url).to be nil
      logger.enable
      expect(logger.enabled?).to be false
    end
  end

  it 'skips enabling for missing url' do
    logger = BaseLogger.new(MOCK_AGENT)
    expect(logger.enabled?).to be false
    expect(logger.url).to be nil
    logger.enable
    expect(logger.enabled?).to be false
  end

  it 'skips enabling for nil url' do
    logger = BaseLogger.new(MOCK_AGENT, url: nil)
    expect(logger.enabled?).to be false
    expect(logger.url).to be nil
    logger.enable
    expect(logger.enabled?).to be false
  end

  it 'skips logging when disabled' do
    URLS_DENIED.each do |url|
      logger = BaseLogger.new(MOCK_AGENT, url: url).disable
      expect(logger.enabled?).to be false
      expect(logger.submit(nil)).to be true # would fail if enabled
    end
  end

  it 'submits to demo url' do
    logger = BaseLogger.new(MOCK_AGENT, url: 'DEMO')
    expect(logger.url).to eql(UsageLoggers.url_for_demo)
    json = String.new
    JsonMessage.start(json, 'test-https', logger.agent, logger.version, Time.now.to_i)
    JsonMessage.stop(json)
    expect(logger.submit(json)).to be true
  end

  it 'submits to demo url via http' do
    logger = BaseLogger.new(MOCK_AGENT, url: UsageLoggers.url_for_demo.gsub('https://', 'http://'))
    expect(logger.url.include?('http://')).to be true
    json = String.new
    JsonMessage.start(json, 'test-http', logger.agent, logger.version, Time.now.to_i)
    JsonMessage.stop(json)
    expect(logger.submit(json)).to be true
  end

  it 'submits to denied url and fails' do
    URLS_DENIED.each do |url|
      logger = BaseLogger.new(MOCK_AGENT, url: url)
      expect(logger.enabled?).to be true
      expect(logger.submit('{}')).to be false
    end
  end

  it 'submits to queue' do
    queue = []
    logger = BaseLogger.new(MOCK_AGENT, queue: queue, url: URLS_DENIED[0])
    expect(logger.url).to be nil
    expect(logger.enabled?).to be true
    expect(queue.length).to be 0
    expect(logger.submit('{}')).to be true
    expect(queue.length).to eql(1)
    expect(logger.submit('{}')).to be true
    expect(queue.length).to eql(2)
  end

end
