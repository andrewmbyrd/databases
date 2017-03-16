include RSpec
require 'bloc_record/base'
require 'bloc_record'
require_relative 'address-bloc-1/models/entry'

RSpec.describe Entry, type: Class do



  BlocRecord.connect_to('address-bloc-1/db/address_bloc.sqlite')

  describe "#find_each" do
    it "gets all instances of Entry" do
      expect(BlocRecord::Base.first).to eq Enumerable
    end
  end


end
