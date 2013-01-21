require 'spec_helper'

describe Yawpa do
  describe 'parse' do
    it "returns everything as arguments when no options present" do
      config = { }
      params = ['one', 'two', 'three', 'four']
      opts, args = Yawpa.parse(config, params)
      opts.should eq([])
      args.should eq(params)
    end
  end
end
