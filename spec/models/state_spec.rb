require 'spec_helper'

RSpec.describe State, type: :model do
  it { should respond_to(:name) }
  it { should respond_to(:latitude) }
  it { should respond_to(:longitude) }
  it { should be_valid }
end
