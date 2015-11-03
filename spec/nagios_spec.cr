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
      Nagios::Bla.check({"s" => "crit_warn"}).should eq({Nagios::CRIT, "a1; a2"})
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

  describe "GenCheck" do
    it "check1" do
      k = Nagios::GenCheck1.new
      k.check
      p k
      Nagios::GenCheck1.check.should eq({Nagios::WARN, "msg 15"})
    end
  end

  it "check_name" do
    Nagios::Prefix.check_name.should eq("prefix")
    Nagios::Prefix.new.check_name.should eq("prefix")
  end
end
