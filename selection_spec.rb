include RSpec
require_relative 'bloc_record/lib/bloc_record/base'
require 'bloc_record'
require_relative 'address-bloc-1/models/entry'

RSpec.describe Entry do

  BlocRecord.connect_to('address-bloc-1/db/address_bloc.sqlite')

  describe "#find_each" do
    it "gets all instances of Entry" do
       expect(Entry.first.name).to eq "Foo One"
    end
  end


end
