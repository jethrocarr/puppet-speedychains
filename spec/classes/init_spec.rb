require 'spec_helper'
describe 'geofirewall' do

  context 'with defaults for all parameters' do
    it { should contain_class('geofirewall') }
  end
end
