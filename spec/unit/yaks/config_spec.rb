require 'spec_helper'

describe Yaks::Config do
  def self.configure(&blk)
    subject(:config) { described_class.new(&blk) }
  end

  context 'defaults' do
    configure {}

    its(:default_format) { should equal :hal }
    its(:policy_class)   { should < Yaks::DefaultPolicy }
    it 'should have empty format options' do
      expect(config.options_for_format(:hal)).to eql({})
    end
  end

  context 'with a default format' do
    configure do
      default_format :json_api
    end

    its(:default_format) { should equal :json_api }
  end

  context 'with a custom policy class' do
    MyPolicy = Struct.new(:options)
    configure do
      policy MyPolicy
    end

    its(:policy_class) { should equal MyPolicy }
    its(:policy)       { should be_a  MyPolicy }
  end

  context 'with a rel template' do
    configure do
      rel_template 'http://rel/foo'
    end

    its(:policy_options) { should eql(rel_template: 'http://rel/foo') }
  end

  context 'with format options' do
    configure do
      format :hal, plural_links: [:self, :profile]
    end

    specify do
      expect(config.options_for_format(:hal)).to eql(plural_links: [:self, :profile])
    end
  end

end
