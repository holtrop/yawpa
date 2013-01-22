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

    it "returns an option's value when nargs = 1" do
      options = {
        opt: {nargs: 1},
      }
      params = ['--opt', 'val', 'arg']
      opts, args = Yawpa.parse(params, options)
      opts[:opt].should eq('val')
      args.should eq(['arg'])
    end

    it "returns an option's values when nargs = 2" do
      options = {
        opt: {nargs: 2},
      }
      params = ['--opt', 'val1', 'val2']
      opts, args = Yawpa.parse(params, options)
      opts[:opt].should eq(['val1', 'val2'])
      args.should eq([])
    end

    it "raises an exception when not enough arguments for an option are given" do
      options = {
        opt: {nargs: 2},
      }
      params = ['--opt', 'val']
      expect { Yawpa.parse(params, options) }.to raise_error
    end

    it "uses --opt=val syntax for an option's value" do
      options = {
        opt: {nargs: 1},
      }
      params = ['--opt=thevalue', 'arg']
      opts, args = Yawpa.parse(params, options)
      opts[:opt].should eq('thevalue')
      args.should eq(['arg'])
    end

    it "uses --opt=val for the first option argument when nargs > 1" do
      options = {
        opt: {nargs: 2},
      }
      params = ['--opt=val1', 'val2', 'arg']
      opts, args = Yawpa.parse(params, options)
      opts[:opt].should eq(['val1', 'val2'])
      args.should eq(['arg'])
    end

    it "returns the last set value when an option is passed twice" do
      options = {
        opt: {nargs: 1},
      }
      params = ['--opt', 'val1', 'arg1', '--opt', 'val2', 'arg2']
      opts, args = Yawpa.parse(params, options)
      opts[:opt].should eq('val2')
      args.should eq(['arg1', 'arg2'])
    end
  end
end
