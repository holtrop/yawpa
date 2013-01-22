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
      args.should be_empty
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

    it "accepts strings as keys for option configuration" do
      options = {
        'crazy-option' => {nargs: 1},
      }
      params = ['xxx', '--crazy-option', 'yyy', 'zzz']
      opts, args = Yawpa.parse(params, options)
      opts['crazy-option'].should eq('yyy')
      args.should eq(['xxx', 'zzz'])
    end

    it "accepts short options corresponding to a long option" do
      options = {
        option: {short: 'o'},
      }
      params = ['-o', 'qqq']
      opts, args = Yawpa.parse(params, options)
      opts[:option].should be_true
      args.should eq(['qqq'])
    end

    it "returns option argument at next position for a short option" do
      options = {
        option: {nargs: 1, short: 'o'},
      }
      params = ['-o', 'val', 'rrr']
      opts, args = Yawpa.parse(params, options)
      opts[:option].should eq('val')
      args.should eq(['rrr'])
    end

    it "returns option argument immediately following short option" do
      options = {
        option: {nargs: 1, short: 'o'},
      }
      params = ['-oval', 'rrr']
      opts, args = Yawpa.parse(params, options)
      opts[:option].should eq('val')
      args.should eq(['rrr'])
    end

    it "handles globbed-together short options" do
      options = {
        a: {short: 'a'},
        b: {short: 'b'},
        c: {short: 'c'},
        d: {short: 'd'},
      }
      params = ['-abc', 'xyz']
      opts, args = Yawpa.parse(params, options)
      opts[:a].should be_true
      opts[:b].should be_true
      opts[:c].should be_true
      opts[:d].should be_nil
      args.should eq(['xyz'])
    end

    it "handles globbed-together short options with values following" do
      options = {
        a: {short: 'a'},
        b: {short: 'b'},
        c: {nargs: 1, short: 'c'},
        d: {short: 'd'},
      }
      params = ['-abcfoo', 'bar']
      opts, args = Yawpa.parse(params, options)
      opts[:a].should be_true
      opts[:b].should be_true
      opts[:c].should eq('foo')
      opts[:d].should be_nil
      args.should eq(['bar'])
    end

    it "handles globbed-together short options with multiple values following" do
      options = {
        a: {short: 'a'},
        b: {short: 'b'},
        c: {nargs: 3, short: 'c'},
        d: {short: 'd'},
      }
      params = ['-abcfoo', 'bar', 'baz']
      opts, args = Yawpa.parse(params, options)
      opts[:a].should be_true
      opts[:b].should be_true
      opts[:c].should eq(['foo', 'bar', 'baz'])
      opts[:d].should be_nil
      args.should be_empty
    end

    it "raises an error on an unknown short option" do
      options = {
        a: {short: 'a'},
      }
      params = ['-ab']
      expect { Yawpa.parse(params, options) }.to raise_error
    end

    it "raises an error when not enough arguments are given to short option" do
      options = {
        a: {nargs: 1, short: 'a'},
      }
      params = ['-a']
      expect { Yawpa.parse(params, options) }.to raise_error
    end

    it "overwrites option value when short option used after long" do
      options = {
        option: {nargs: 1, short: 'o'},
      }
      params = ['--option', 'VALUE', '-o', 'NEW_VALUE']
      opts, args = Yawpa.parse(params, options)
      opts[:option].should eq('NEW_VALUE')
      args.should be_empty
    end

    it "ignores options after arguments in posix_order mode" do
      options = {
        one: {},
        two: {},
      }
      params = ['--one', 'arg', '--two']
      opts, args = Yawpa.parse(params, options, posix_order: true)
      opts[:one].should be_true
      opts[:two].should be_false
      args.should eq(['arg', '--two'])
    end
  end
end
