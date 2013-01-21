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

    it "returns boolean options which are set" do
      options = {
        one: {},
        two: {},
        three: {},
      }
      params = ['--one', 'arg', '--two', 'arg2']
      opts, args = Yawpa.parse(params, options)
      opts.include?(:one).should be_true
      opts.include?(:two).should be_true
      opts.include?(:three).should be_false
      args.should eq(['arg', 'arg2'])
    end
  end
end
