require_relative '../spec_helper'

class AnotherFile 
  include Fieldy::Writer

  field :first_name, 5
  field :last_name, 5
end

class AWriterWithASkip
  include Fieldy::Writer

  field :first_name, 5
  skip 20
  field :last_name, 5
end

class AWriterWithAHardcodedValue
  include Fieldy::Writer
  field :first_name, 5
  hardcode "abcdefg"
  field :last_name, 5
end

class AWriterWithAFillValue
  include Fieldy::Writer
  field :first_name, 5
  skip 5, fill: '*'
  field :last_name, 5
end

describe Fieldy::Writer do

  it "should create attr_accessors for each field" do
    file = AnotherFile.new

    name = SecureRandom.uuid
    file.first_name = name
    file.first_name.must_equal name

    name = SecureRandom.uuid
    file.last_name = name
    file.last_name.must_equal name
  end

  describe "writing a file" do

    it "should have the proper length" do
      a = AnotherFile.write(:first_name => "jimmy", :last_name => "fall")
      a.length.must_equal 10
    end

  end

  describe "to_s" do

    it "should return the full line" do

      file = AnotherFile.new.tap do |f|
               f.first_name = 'test'
               f.last_name  = 'test2'
             end
      file.to_s.must_equal('test test2') 
    end

  end

  describe "skipping" do
    it "should return the appropriate number of spaces" do
      writer = AWriterWithASkip.new
      writer.to_s.must_equal "                              "
    end

    it "should allow for a different fill value" do
      writer = AWriterWithAFillValue.new
      writer.to_s.must_equal '     *****     '
    end
  end

  describe "hardcoded values" do
    it "should hardcode the value" do
      AWriterWithAHardcodedValue.new.to_s.must_equal "     abcdefg     "
    end
  end

  describe "fields" do

    it "should contain a record for each field" do
      AnotherFile.fields.tap do |fields|
        fields.count.must_equal 2
        fields[0][:key].must_equal :first_name
        fields[0][:length].must_equal 5
        fields[1][:key].must_equal :last_name
        fields[1][:length].must_equal 5
        fields.each { |f| f[:type].nil?.must_equal true }
      end

      AWriterWithASkip.fields.tap do |fields|
        fields.count.must_equal 3
        fields[0][:key].must_equal :first_name
        fields[1][:key].must_equal nil
        fields[1][:length].must_equal 20
        fields[2][:key].must_equal :last_name
        fields[2][:length].must_equal 5
        fields.each { |f| f[:type].nil?.must_equal true }
      end
        
    end

    describe "incrementing the start_at for each field" do

      it "should use start_at to record the starting point of each field" do

        AnotherFile.fields.tap do |fields|
          fields[0][:starts_at].must_equal 0
          fields[1][:starts_at].must_equal 5
        end

        AWriterWithASkip.fields.tap do |fields|
          fields[0][:starts_at].must_equal 0
          fields[1][:starts_at].must_equal 5
          fields[2][:starts_at].must_equal 25
        end

      end

    end

  end

end
