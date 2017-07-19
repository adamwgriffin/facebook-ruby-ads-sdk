require 'spec_helper'

# rspec spec/facebook_ads/facebook_ads_spec.rb
describe FacebookAds do
  describe '#base_uri' do
    it 'is currently v2.9' do
      expect(FacebookAds.base_uri.include?('2.9')).to be_truthy
    end

    it 'can be set to v2.10' do
      FacebookAds.base_uri = 'https://graph.facebook.com/v2.10'
      expect(FacebookAds.base_uri.include?('2.10')).to be_truthy
    end
  end
end
