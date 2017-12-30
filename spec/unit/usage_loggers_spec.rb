# coding: utf-8
# © 2016-2018 Resurface Labs LLC

require 'resurfaceio/all'

describe UsageLoggers do

  it 'provides default url' do
    url = UsageLoggers.url_by_default
    expect(url).to be nil
  end

end
