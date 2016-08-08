# -*- encoding : utf-8 -*-
require 'spec_helper'

EXAMPLE_TAG_NAME = "example tag"
EXAMPLE_USER_ID = 10

describe Tag do
  context "プロパティを設定しない場合" do
    before do
      @tag = Tag.new
      @tag.valid?
      @expected_errors_num = 2
    end
    subject { @tag }
    it { should have(@expected_errors_num).errors }
  end
  describe "#name" do
    before do
      @tag = Tag.new
      @tag.name = EXAMPLE_TAG_NAME
      @expected_errors_num = 1
    end
    subject { @tag }
    it { subject.name.should eql EXAMPLE_TAG_NAME }
    it { should_not be_valid }
    it { should have(@expected_errors_num).errors_on(:user_id) }
  end
  context "#user_id" do
    before do
      @tag = Tag.new
      @tag.user_id = EXAMPLE_USER_ID
      @expected_errors_num = 1
    end
    subject { @tag }
    it { subject.user_id.should eql EXAMPLE_USER_ID }
    it { should_not be_valid }
    it { should have(@expected_errors_num).errors_on(:name) }
  end
  context "name, user_id を設定した場合" do
    before do
      @tag = Tag.new
      @tag.name = EXAMPLE_TAG_NAME
      @tag.user_id = EXAMPLE_USER_ID
    end
    subject { @tag }
    it { should be_valid }
  end
end
