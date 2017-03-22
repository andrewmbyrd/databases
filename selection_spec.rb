include RSpec
require_relative 'bloc_record/lib/bloc_record/base'
require 'bloc_record'
require_relative 'address-bloc-1/models/entry'

RSpec.describe Entry do

  BlocRecord.connect_to('address-bloc-1/db/address_bloc.sqlite')

  describe "SELCTION" do
    it "gets all instances of Entry" do
       list = Entry.find_each(1,2) do |entry|
         puts entry.name
       end
    end


    it "finds an instance of Entry" do
      expect(Entry.find_one(2).name).to eq("Foo Two")
    end

    it "takes a random instance of Entry" do
      puts Entry.take(1)
    end

    it "finds an instance by attribute" do
      expect(Entry.find_by('phone_number', '999-999-9999').email).to eq "foo_one@gmail.com"
    end

    it "gets a list of entries" do 
      expect(Entry.find(8)).to eq ("Foo Two")
    end

  end



end
