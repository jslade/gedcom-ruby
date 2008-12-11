require 'gedcom'
include GEDCOM

describe Parser do
  GEDCOMS = File.dirname(__FILE__)+"/gedcoms"
  SIMPLE = "#{GEDCOMS}/simple.ged"

  before(:each) do
    @tag_count = { :all => 0 }
    @parser = GEDCOM::Parser.new
    @parser.before :any do |tag,data|
      tag = tag.join('_')
      @tag_count[tag] ||= 0
      @tag_count[tag] += 1
      @tag_count[:all] += 1
    end
  end
  
  it "can be initialized with block" do
    parser = GEDCOM::Parser.new do
      before 'INDI' do
      end
    end
  end

  it "can count individual tags, before and after" do
    count_before = 0
    count_after = 0
    @parser.before 'INDI' do |data| 
      count_before += 1
    end
    @parser.after 'INDI' do |data| 
      count_after += 1
    end
    @parser.parse SIMPLE
    count_before.should == 3
    count_after.should == 3
  end


  it "should unwind all the way" do
    after_trlr = false
    @parser.after 'TRLR' do
      after_trlr = true
    end
    @parser.parse SIMPLE
    after_trlr.should == true
  end


  it "should use :any as default" do
    @parser.parse SIMPLE
    @tag_count[:all].should == 48
    @tag_count['INDI'].should == 3
    @tag_count['FAM'].should == 1
    @tag_count['FAM_MARR_DATE'].should == 1
  end


  it "should parse torture-test cases okay" do
  end


end
