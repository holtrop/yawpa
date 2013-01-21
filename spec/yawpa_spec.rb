require 'spec_helper'

describe Yawpa do
  describe 'parse' do
    it "returns everything as arguments when no options present" do
      config = { }
      params = ['one', 'two', 'three', 'four']
      Yawpa.parse(config, params).should eq([[], params])
    end
  end
end
