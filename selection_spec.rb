include RSpec
require 'bloc_record/base'
require 'bloc_record'
require_relative 'address-bloc-1/models/entry'

RSpec.describe Entry do

  BlocRecord.connect_to('address-bloc-1/db/address_bloc.sqlite')

  describe "#find_each" do
    it "gets all instances of Entry" do
      puts Entry.find(1).name
    end
  end


end
