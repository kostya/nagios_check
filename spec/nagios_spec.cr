require "./spec_helper"
require "./nagios_support"

describe "Nagios::Bla" do
  describe "check" do
    it "ok run" do
      Nagios::Bla.check.should eq({Nagios::OK, "a5"})
    end

    it "crit" do
      Nagios::Bla.check({"s" => "crit"}).should eq({Nagios::CRIT, "a1"})
    end

    it "warn" do
      Nagios::Bla.check({"s" => "warn"}).should eq({Nagios::WARN, "a2"})
    end

    it "raise" do
      Nagios::Bla.check({"s" => "raise"}).should eq({Nagios::OTHER, "Exception: a3"})
    end

    it "other" do
      Nagios::Bla.check({"s" => "other"}).should eq({Nagios::OTHER, "a4"})
    end

    it "ok" do
      Nagios::Bla.check({"s" => "ok"}).should eq({Nagios::OK, "a5"})
    end

    it "crit_warn" do
      Nagios::Bla.check({"s" => "crit_warn"}).should eq({Nagios::CRIT, "a1 \\ a2"})
    end
  end

  describe "runner" do
    it "ok run throught lookup" do
      Nagios::Check.run("bla").should eq({Nagios::OK, "a5"})
      Nagios::Check.run("bla", {"s" => "crit"}).should eq({Nagios::CRIT, "a1"})
    end

    it "when undefined check_name" do
      Nagios::Check.run("asdf").should eq({Nagios::OTHER, "Not found class for 'asdf'"})
      Nagios::Check.run("").should eq({Nagios::OTHER, "Not found class for ''"})
    end
  end

  describe "Nagios::BlockObj" do
    it "should be ok" do
      Nagios::BlockObj.check({"s" => "1"}).should eq({Nagios::OK, "1"})
    end

    it "should be crit" do
      Nagios::BlockObj.check({"s" => "2"}).should eq({Nagios::CRIT, "2"})
    end
  end

  it "message_prefix" do
    Nagios::Prefix.check({"s" => "1"}).should eq({Nagios::CRIT, "some 1"})
  end

  it "message_prefix" do
    Nagios::Prefix.check({"s" => "2"}).should eq({Nagios::OK, "some 2"})
  end

  describe "FastCheck" do
    it "check1" do
      Nagios::FastCheck1.check.should eq({Nagios::CRIT, "red(9):0.9; red(10):1 \\ red(7):0.7; red(8):0.8"})
      Nagios::FastCheck1.check({"to" => "6"}).should eq({Nagios::OK, "red(0):0; red(1):0.1; red(2):0.2; red(3):0.3; red(4):0.4; red(5):0.5; red(6):0.6"})
      Nagios::FastCheck1.check({"to" => "7"}).should eq({Nagios::WARN, "red(7):0.7"})
      Nagios::FastCheck1.check({"dir" => "right"}).should eq({Nagios::CRIT, "red(0):0; red(1):0.1; red(2):0.2; red(3):0.3 \\ red(4):0.4; red(5):0.5; red(6):0.6; red(7):0.7; red(8):0.8; red(9):0.9"})
    end

    it "check2" do
      Nagios::FastCheck2.check.should eq({Nagios::OK, "red:0.1"})
      Nagios::FastCheck2.check({"r" => "0.2"}).should eq({Nagios::WARN, "red:0.2"})
      Nagios::FastCheck2.check({"r" => "0.3"}).should eq({Nagios::CRIT, "red:0.3"})
      Nagios::FastCheck2.check({"r" => "0.4"}).should eq({Nagios::OTHER, "red:0.4"})
    end

    it "check3" do
      Nagios::FastCheck3.check.should eq({Nagios::CRIT, "red:false"})
      Nagios::FastCheck3.check({"r" => "0.2"}).should eq({Nagios::OK, "red:true"})
    end

    it "check_array" do
      Nagios::FastCheckArray.check({"r" => "5"}).should eq({Nagios::OK, "red:5"})
      Nagios::FastCheckArray.check({"r" => "12"}).should eq({Nagios::CRIT, "red:12"})
      Nagios::FastCheckArray.check({"r" => "13"}).should eq({Nagios::OTHER, "red:13"})
    end

    it "check_range" do
      Nagios::FastCheckRange.check({"r" => "5"}).should eq({Nagios::OK, "red:5"})
      Nagios::FastCheckRange.check({"r" => "16"}).should eq({Nagios::CRIT, "red:16"})
      Nagios::FastCheckRange.check({"r" => "28"}).should eq({Nagios::OTHER, "red:28"})
    end

    it "check_value" do
      Nagios::FastCheckValue.check.should eq({Nagios::OK, "1"})
      Nagios::FastCheckValue2.check.should eq({Nagios::OTHER, "jopa"})
      Nagios::FastCheckValue3.check.should eq({Nagios::WARN, "2"})
    end
  end

  it "check_name" do
    Nagios::Prefix.check_name.should eq("prefix")
    Nagios::Prefix.new.check_name.should eq("prefix")
  end
end
