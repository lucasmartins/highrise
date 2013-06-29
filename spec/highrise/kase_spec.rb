require 'spec_helper'

describe Highrise::Kase do
  it { should be_a_kind_of Highrise::Subject }

  it_should_behave_like "a paginated class"

  it "#close!" do
    mocked_now = Time.parse("Wed Jan 14 15:43:11 -0200 2009")
    Time.should_receive(:now).and_return(mocked_now)
    subject.should_receive(:update_attribute).with(:closed_at, mocked_now.utc)
    subject.close!
  end

  it "#open!" do
    subject.should_receive(:update_attribute).with(:closed_at, nil)
    subject.open!
  end

  it ".all_open_across_pages" do
    subject.class.should_receive(:find).with(:all,{:from=>"/kases/open.xml",:params=>{:n=>0}}).and_return(["things"])
    subject.class.should_receive(:find).with(:all,{:from=>"/kases/open.xml",:params=>{:n=>1}}).and_return([])
    subject.class.all_open_across_pages.should == ["things"]
  end

  it ".all_closed_across_pages" do
    subject.class.should_receive(:find).with(:all,{:from=>"/kases/closed.xml",:params=>{:n=>0}}).and_return(["things"])
    subject.class.should_receive(:find).with(:all,{:from=>"/kases/closed.xml",:params=>{:n=>1}}).and_return([])
    subject.class.all_closed_across_pages.should == ["things"]
  end

  if http_testing?
    it "should create a Case" do
      parties = Highrise::Party.find_all_across_pages()

      p = parties[0]
      kase = Highrise::Kase.new(name: 'test-case',parties:[p])
      valid = kase.valid?
      expect(valid).to be_true
      result = kase.save
      expect(result).to be_true

    end
  end
end
