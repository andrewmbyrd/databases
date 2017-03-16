include RSpec
require 'bloc_record/base'
require 'bloc_record'
class Entry < BlocRecord::Base
end
RSpec.describe Entry, type: Class do



  BlocRecord.connect_to('db/address_bloc.sqlite')

  describe "find_each" do
    it "gets all instances of Entry" do
      expect(Entry.find_one).to eq Enumerable
    end
  end


end
