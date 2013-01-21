require 'spec_helper'

describe Yawpa do
  describe 'parse' do
    it "returns everything as arguments when no options present" do
      options = { }
      params = ['one', 'two', 'three', 'four']
      opts, args = Yawpa.parse(params, options)
      opts.should eq({})
      args.should eq(params)
    end

    it "raises an exception when an invalid option is passed" do
      options = { }
      params = ['one', '--option', 'two']
      expect { Yawpa.parse(params, options) }.to raise_error
    end
  end
end
