require 'spec_helper'

RSpec.describe Country, type: :model do
  before (:each) do
    @country = FactoryGirl.build(:country)
  end

  subject { @country }
  it { should respond_to(:name) }
  it { should respond_to(:iso) }
  it { should respond_to(:latitude) }
  it { should respond_to(:longitude) }
  it { should be_valid }

  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name) }
  it { should validate_uniqueness_of(:iso) }
  it { should validate_length_of(:iso).is_equal_to(2).with_message('should be 2 characters') }
end
