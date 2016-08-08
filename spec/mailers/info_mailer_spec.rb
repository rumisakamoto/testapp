require "spec_helper"

describe InfoMailer do
  describe "daily" do
    let(:mail) { InfoMailer.daily }

    it "renders the headers" do
      mail.subject.should eq("Daily")
      mail.to.should eq(["to@example.org"])
      mail.from.should eq(["from@example.com"])
    end

    it "renders the body" do
      mail.body.encoded.should match("Hi")
    end
  end

  describe "weekly" do
    let(:mail) { InfoMailer.weekly }

    it "renders the headers" do
      mail.subject.should eq("Weekly")
      mail.to.should eq(["to@example.org"])
      mail.from.should eq(["from@example.com"])
    end

    it "renders the body" do
      mail.body.encoded.should match("Hi")
    end
  end

  describe "monthly" do
    let(:mail) { InfoMailer.monthly }

    it "renders the headers" do
      mail.subject.should eq("Monthly")
      mail.to.should eq(["to@example.org"])
      mail.from.should eq(["from@example.com"])
    end

    it "renders the body" do
      mail.body.encoded.should match("Hi")
    end
  end

end
