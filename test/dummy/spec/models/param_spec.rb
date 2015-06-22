require "rails_helper"

module OneboxApiDoc
  describe Param do

    before do
      @base = OneboxApiDoc.base
      @doc = @base.add_doc(ApiDoc, 1, 1)
    end

    describe "initialize" do

      it "set correct id name and type" do
        @param = OneboxApiDoc::Param.new doc_id: @doc.object_id, name: :status, type: :string
        expect(@param.name).to eq "status"
        expect(@param.type).to eq "String"
      end

      it "set correct param options" do
        @param = OneboxApiDoc::Param.new doc_id: @doc.object_id, name: :status, type: :string, 
          desc: 'status',
          permission_ids: [ 3,4,5 ],
          required: false,
          default: 'all',
          parent_id: 22,
          from_version_id: 44
        expect(@param).not_to eq nil
        expect(@param.permission_ids).to eq [ 3,4,5 ]
        expect(@param.required).to eq false
        expect(@param.default).to eq 'all'
        expect(@param.parent_id).to eq 22
        expect(@param.from_version_id).to eq 44
      end

      it "'s others option is optional" do
        @param = OneboxApiDoc::Param.new doc_id: @doc.object_id, name: :address, type: :object
        expect(@param).not_to eq nil
      end

      describe "validations" do
        it "set correct validation message" do
          @param = OneboxApiDoc::Param.new doc_id: @doc.object_id, name: :status, type: :string, validates: { min: -1 }
          expect(@param.validates).to include 'cannot be less than -1'

          @param = OneboxApiDoc::Param.new doc_id: @doc.object_id, name: :status, type: :string, validates: { max: 10 }
          expect(@param.validates).to include 'cannot be more than 10'

          @param = OneboxApiDoc::Param.new doc_id: @doc.object_id, name: :status, type: :string, validates: { within: ["online", "offline", "all"] }
          expect(@param.validates).to include 'must be within ["online", "offline", "all"]'

          @param = OneboxApiDoc::Param.new doc_id: @doc.object_id, name: :status, type: :string, validates: { pattern: "/[A-Za-z0-9]/" }
          expect(@param.validates).to include 'must match format /[A-Za-z0-9]/'

          @param = OneboxApiDoc::Param.new doc_id: @doc.object_id, name: :status, type: :string, validates: { email: true }
          expect(@param.validates).to include 'must be in email format'

          @param = OneboxApiDoc::Param.new doc_id: @doc.object_id, name: :status, type: :string, validates: { min_length: 6 }
          expect(@param.validates).to include 'cannot have length less than 6'

          @param = OneboxApiDoc::Param.new doc_id: @doc.object_id, name: :status, type: :string, validates: { max_length: 10 }
          expect(@param.validates).to include 'cannot have length more than 10'
        end
      end

      # describe "nested params" do
      #   it "set correct nested param" do
      #     @param = OneboxApiDoc::Param.new doc_id: 1, :address, :object, 
      #     desc: 'address object',
      #     permissions: [ :guest, :admin, :member ],
      #     required: true do
      #       param :address_no, :string,
      #         desc: 'address number',
      #         permissions: [ :guest, :admin, :member ],
      #         required: true
      #       param :road, :string,
      #         desc: 'road',
      #         permissions: [ :guest, :admin, :member ],
      #         required: false
      #     end
      #     expect(@param._params).to be_an Array
      #     first_param = @param._params.first
      #     expect(first_param._name).to eq "address_no"
      #     expect(first_param._type).to eq "String"
      #     expect(first_param._desc).to eq "address number"
      #     expect(first_param._permissions).to eq [ "guest", "admin", "member" ]
      #     expect(first_param._required).to eq true
      #     second_param = @param._params.last
      #     expect(second_param._name).to eq "road"
      #     expect(second_param._type).to eq "String"
      #     expect(second_param._desc).to eq "road"
      #     expect(second_param._permissions).to eq [ "guest", "admin", "member" ]
      #     expect(second_param._required).to eq false
      #   end

      describe "nested params" do
        it "set correct parent_id" do
          @param = OneboxApiDoc::Param.new doc_id: @doc.object_id, name: :address, type: :object, 
            desc: 'address object',
            permissions: [ :guest, :admin, :member ],
            required: true,
            parent_id: 55
          expect(@param.parent_id).to eq 55
        end
      end
    end

    describe "params" do
      it "return correct params"
    end

    describe "doc" do
      it "return correct doc"
    end

    describe "parent" do
      it "return correct parent param"
    end

    describe "permissions" do
      it "return correct permissions array"
    end

    describe "permissions=()" do
      it "set correct permission_ids"
    end

  end
end