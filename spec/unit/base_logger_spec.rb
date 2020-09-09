# coding: utf-8
# © 2016-2020 Resurface Labs Inc.

require 'json'
require 'resurfaceio/all'
require_relative 'helper'

describe BaseLogger do

  it 'creates instance' do
    logger = BaseLogger.new(MOCK_AGENT)
    expect(logger.nil?).to be false
    expect(logger.agent).to eql(MOCK_AGENT)
    expect(logger.enableable?).to be false
    expect(logger.enabled?).to be false
    expect(logger.queue).to be nil
    expect(logger.url).to be nil
  end

  it 'creates multiple instances' do
    agent1 = 'agent1'
    agent2 = 'AGENT2'
    agent3 = 'aGeNt3'
    url1 = 'http://resurface.io'
    url2 = 'http://whatever.com'
    logger1 = BaseLogger.new(agent1, url1)
    logger2 = BaseLogger.new(agent2, url: url2)
    logger3 = BaseLogger.new(agent3, url: DEMO_URL)

    expect(logger1.agent).to eql(agent1)
    expect(logger1.enableable?).to be true
    expect(logger1.enabled?).to be true
    expect(logger1.url).to eql(url1)
    expect(logger2.agent).to eql(agent2)
    expect(logger2.enableable?).to be true
    expect(logger2.enabled?).to be true
    expect(logger2.url).to eql(url2)
    expect(logger3.agent).to eql(agent3)
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

  it 'has valid host' do
    host = BaseLogger.host_lookup
    expect(host).not_to be nil
    expect(host).to be_kind_of String
    expect(host.length).to be > 0
    expect(host).not_to eql('unknown')
    expect(host).to eql(BaseLogger.new(MOCK_AGENT).host)
  end

  it 'has valid metadata id' do
    metadata_id = BaseLogger.new(MOCK_AGENT).metadata_id
    expect(metadata_id).not_to be nil
    expect(metadata_id).to be_kind_of String
    expect(metadata_id.length).to eql(20)
  end

  it 'has valid version' do
    version = BaseLogger.version_lookup
    expect(version).not_to be nil
    expect(version).to be_kind_of String
    expect(version.length).to be > 0
    expect(version).to start_with('2.1.')
    expect(version.include?('\\')).to be false
    expect(version.include?('\"')).to be false
    expect(version.include?('\'')).to be false
    expect(version).to eql(BaseLogger.new(MOCK_AGENT).version)
  end

  it 'performs enabling when expected' do
    logger = BaseLogger.new(MOCK_AGENT, url: DEMO_URL, enabled: false)
    expect(logger.enableable?).to be true
    expect(logger.enabled?).to be false
    expect(logger.url).to eql(DEMO_URL)
    logger.enable
    expect(logger.enabled?).to be true

    logger = BaseLogger.new(MOCK_AGENT, queue: [], enabled: false)
    expect(logger.enableable?).to be true
    expect(logger.enabled?).to be false
    expect(logger.url).to be nil
    logger.enable.disable.enable
    expect(logger.enabled?).to be true
  end

  it 'skips enabling for invalid urls' do
    MOCK_URLS_INVALID.each do |url|
      logger = BaseLogger.new(MOCK_AGENT, url: url)
      expect(logger.enableable?).to be false
      expect(logger.enabled?).to be false
      expect(logger.url).to be nil
      logger.enable
      expect(logger.enabled?).to be false
    end
  end

  it 'skips enabling for missing url' do
    logger = BaseLogger.new(MOCK_AGENT)
    expect(logger.enableable?).to be false
    expect(logger.enabled?).to be false
    expect(logger.url).to be nil
    logger.enable
    expect(logger.enabled?).to be false
  end

  it 'skips enabling for nil url' do
    logger = BaseLogger.new(MOCK_AGENT, url: nil)
    expect(logger.enableable?).to be false
    expect(logger.enabled?).to be false
    expect(logger.url).to be nil
    logger.enable
    expect(logger.enabled?).to be false
  end

  it 'submits to demo url' do
    logger = BaseLogger.new(MOCK_AGENT, url: DEMO_URL)
    expect(logger.url).to eql(DEMO_URL)
    message = [
        ['agent', logger.agent],
        ['version', logger.version],
        ['now', MOCK_NOW],
        ['protocol', 'https']
    ]
    msg = JSON.generate(message)
    expect(parseable?(msg)).to be true
    logger.submit(msg)
    expect(logger.submit_failures).to eql(0)
    expect(logger.submit_successes).to eql(1)
  end

  it 'submits to demo url via http' do
    logger = BaseLogger.new(MOCK_AGENT, url: DEMO_URL.gsub('https://', 'http://'))
    expect(logger.url.include?('http://')).to be true
    message = [
        ['agent', logger.agent],
        ['version', logger.version],
        ['now', MOCK_NOW],
        ['protocol', 'http']
    ]
    msg = JSON.generate(message)
    expect(parseable?(msg)).to be true
    logger.submit(msg)
    expect(logger.submit_failures).to eql(0)
    expect(logger.submit_successes).to eql(1)
  end

  it 'submits to demo url without compression' do
    logger = BaseLogger.new(MOCK_AGENT, url: DEMO_URL)
    logger.skip_compression = true
    expect(logger.skip_compression?).to be true
    message = [
        ['agent', logger.agent],
        ['version', logger.version],
        ['now', MOCK_NOW],
        ['protocol', 'https'],
        ['skip_compression', 'true']
    ]
    msg = JSON.generate(message)
    expect(parseable?(msg)).to be true
    logger.submit(msg)
    expect(logger.submit_failures).to eql(0)
    expect(logger.submit_successes).to eql(1)
  end

  it 'submits to denied url' do
    MOCK_URLS_DENIED.each do |url|
      logger = BaseLogger.new(MOCK_AGENT, url: url)
      expect(logger.enableable?).to be true
      expect(logger.enabled?).to be true
      logger.submit('{}')
      expect(logger.submit_failures).to eql(1)
      expect(logger.submit_successes).to eql(0)
    end
  end

  it 'submits to queue' do
    queue = []
    logger = BaseLogger.new(MOCK_AGENT, queue: queue, url: MOCK_URLS_DENIED[0])
    expect(logger.queue).to be(queue)
    expect(logger.url).to be nil
    expect(logger.enableable?).to be true
    expect(logger.enabled?).to be true
    expect(queue.length).to be 0
    logger.submit('{}')
    expect(queue.length).to eql(1)
    logger.submit('{}')
    expect(queue.length).to eql(2)
    expect(logger.submit_failures).to eql(0)
    expect(logger.submit_successes).to eql(2)
  end

  it 'silently ignores unexpected option types' do
    logger = BaseLogger.new(MOCK_AGENT, [])
    expect(logger.enableable?).to be false
    expect(logger.enabled?).to be false
    expect(logger.queue).to be(nil)
    expect(logger.url).to be nil

    logger = BaseLogger.new(MOCK_AGENT, url: true)
    expect(logger.enableable?).to be false
    expect(logger.enabled?).to be false
    expect(logger.queue).to be(nil)
    expect(logger.url).to be nil

    logger = BaseLogger.new(MOCK_AGENT, url: [])
    expect(logger.enableable?).to be false
    expect(logger.enabled?).to be false
    expect(logger.queue).to be(nil)
    expect(logger.url).to be nil

    logger = BaseLogger.new(MOCK_AGENT, url: 23)
    expect(logger.enableable?).to be false
    expect(logger.enabled?).to be false
    expect(logger.queue).to be(nil)
    expect(logger.url).to be nil
  end

  it 'uses skip options' do
    logger = BaseLogger.new(MOCK_AGENT, url: DEMO_URL)
    expect(logger.skip_compression?).to be false
    expect(logger.skip_submission?).to be false

    logger.skip_compression = true
    expect(logger.skip_compression?).to be true
    expect(logger.skip_submission?).to be false

    logger.skip_compression = false
    logger.skip_submission = true
    expect(logger.skip_compression?).to be false
    expect(logger.skip_submission?).to be true
  end

end
