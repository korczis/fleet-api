require 'spec_helper'

describe Fleet do

  after do
    Fleet.reset
  end

  describe '.new' do

    it 'returns a Fleet::Client' do
      expect(Fleet.new).to be_a Fleet::Client
    end

    context 'when no options specified' do

      Fleet::Configuration::VALID_OPTIONS_KEYS.each do |option|

        it "new Fleet::Client inherits :#{option} default from Fleet" do
          expect(Fleet.new.send(option)).to eq Fleet.send(option)
        end
      end
    end

    context 'when options are specified' do

      Fleet::Configuration::VALID_OPTIONS_KEYS.each do |option|

        it "new Fleet::Client receives specified :#{option} value" do
          expect(Fleet.new({option => 'foo'}).send(option)).to eq 'foo'
        end
      end
    end
  end

  describe '.fleet_api_url' do

    let(:url) { 'http://foo.com/bar' }

    before do
      stub_const('Fleet::Configuration::DEFAULT_ETCD_API_URL', url)
      Fleet.reset
    end

    it 'defaults to the value of DEFAULT_ETCD_API_URL' do
      expect(Fleet.fleet_api_url).to eq url
    end
  end

  describe '.open_timeout' do
    it 'defaults to 2' do
      expect(Fleet.open_timeout).to eq 2
    end
  end

  describe '.read_timeout' do
    it 'defaults to 5' do
      expect(Fleet.read_timeout).to eq 5
    end
  end

  describe '.ssl_options' do
    it 'defaults to { verify: false }' do
      expect(Fleet.ssl_options).to eq(verify: false)
    end
  end

  describe '.proxy' do
    it 'defaults to nil' do
      expect(Fleet.proxy).to be_nil
    end
  end

  describe '.configure' do
    it "accepts a block" do
      expect { Fleet.configure {} }.to_not raise_error
    end

    it "yields self" do
      Fleet.configure { |conf| expect(conf).to be(Fleet) }
    end

    it "returns true" do
      expect(Fleet.configure {}).to eq true
    end
  end
end
