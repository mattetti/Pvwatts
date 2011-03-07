require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Pvwatts do
  
  before(:all) do
    @pdata = Pvwatts.new(PVWATTS_SPEC_KEY).yearly_production(   :latitude    => 32.95850, 
                                              :longitude   => -117.12206, 
                                              :dc_rating   => 4.0, 
                                              :tilt        => 45, 
                                              :orientation => 180,
                                              :shading     => 0)
  end
  
  it "should fetch the yearly production data" do
    @pdata['jan'].should == 496
    @pdata['feb'].should == 469
    @pdata['mar'].should == 539
    @pdata['apr'].should == 525
    @pdata['may'].should == 539
    @pdata['jun'].should == 498
    @pdata['jul'].should == 526
    @pdata['aug'].should == 554
    @pdata['sep'].should == 540
    @pdata['oct'].should == 536
    @pdata['nov'].should == 508
    @pdata['dec'].should == 471
    @pdata['year'].should == 6203
  end
  
end
