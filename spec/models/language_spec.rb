require 'spec_helper'

RSpec.describe Language, type: :model do
  before(:each) do
    @language = FactoryGirl.build(:language)
  end

  subject { @language }

  it { should respond_to(:name) }
  it { should be_valid }
  it { should validate_presence_of(:name) }
end
