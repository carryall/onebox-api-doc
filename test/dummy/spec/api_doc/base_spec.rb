require "rails_helper"

module OneboxApiDoc
  describe Base do

    before do
      @base = OneboxApiDoc.base
      @base.send(:set_default_value)
      @base.unload_document
    end

    describe "initialize" do
      it "set default value" do
        expect_any_instance_of(OneboxApiDoc::Base).to receive :set_default_value
        OneboxApiDoc::Base.new
      end
      it "set correct default value" do
        expect(@base.apps).to eq []
        expect(@base.versions).to eq []
        expect(@base.docs).to eq []
        expect(@base.resources).to eq []
        expect(@base.params).to eq []
      end
    end

    describe "reload_document" do
      it "unload document and load it again" do
        expect(@base).to receive :load_document
        expect(@base).to receive :unload_document
        @base.reload_document
      end
    end

    describe "load_document", hhh: true do
      it "load document class" do
        @base.load_document
        expect{ UsersApiDoc }.not_to raise_error
      end
    end

    describe "unload_document" do
      it "does not load document class if the class wasn't load yet" do
        @base.unload_document
        expect{ UsersApiDoc }.to raise_error
      end
      it "unload document class if the class was loaded" do
        @base.load_document
        @base.unload_document
        expect{ UsersApiDoc }.to raise_error
      end
      it "reset attributes to default value" do
        expect(@base).to receive :set_default_value
        @base.unload_document
      end
    end

    describe "api_docs_paths" do
      it "return correct array of document paths" do
        expect(@base.api_docs_paths).to eq Dir.glob(Rails.root.join(*OneboxApiDoc::Engine.api_docs_matcher.split("/")))
      end
    end

    describe "main_app" do
      it "return correct app" do
        main_app = @base.main_app
        expect(main_app).to be_an OneboxApiDoc::App
        expect(main_app.name).to eq "main"
        expect(main_app.is_extension?).to eq false
      end
      it "add new app if main app not already exist" do
        @base.apps = []
        expect{ @base.main_app }.to change(@base.apps, :size).by 1
      end
      it "does not add new app if main app already exist" do
        @base.add_app "main"
        expect{ @base.main_app }.not_to change(@base.apps, :size)
      end
    end

    describe "extension_apps" do
      before do
        @base.add_app "extension1"
        @base.add_app "extension2"
      end
      it "return correct array of apps" do
        extension_apps = @base.extension_apps
        expect(extension_apps).to be_an Array
        expect(extension_apps.first).to be_an OneboxApiDoc::App
        expect(extension_apps.first.name).to eq 'extension1'
        expect(extension_apps.first.is_extension?).to eq true
        expect(extension_apps.second).to be_an OneboxApiDoc::App
        expect(extension_apps.second.name).to eq 'extension2'
        expect(extension_apps.second.is_extension?).to eq true
      end
    end

    describe "default_version" do
      it "return correct version" do
        default_version = @base.default_version
        expect(default_version).to be_an OneboxApiDoc::Version
        expect(default_version.name).to eq OneboxApiDoc::Engine.default_version
        expect(default_version.is_extension?).to eq false
        expect(default_version.app.name).to eq 'main'
      end
      it "add new version if main version not already exist" do
        @base.versions = []
        expect{ @base.default_version }.to change(@base.versions, :size).by 1
      end
      it "does not add new version if main version already exist" do
        @base.add_version OneboxApiDoc::Engine.default_version
        expect{ @base.default_version }.not_to change(@base.versions, :size)
      end
    end

    describe "main_versions" do
      before do
        main_app = @base.add_app "main"
        @core_versions = []
        @core_versions << @base.add_version("0.0.2")
        @core_versions << @base.add_version("0.0.2.1")
        @core_versions << @base.add_version("0.0.2.2")
        @extension_versions = []
        @extension_versions << @base.add_extension_version("0.0.2", "extension_name")
        @extension_versions << @base.add_extension_version("0.1.2", "extension_name")
        @extension_versions << @base.add_extension_version("0.1.2.1", "extension_name")
        @extension_versions << @base.add_extension_version("1.0.2.2", "extension_name")
      end
      it "return array of version which belongs to main app" do
        versions = @base.main_versions
        expect(versions).to be_an Array
        expect(versions.size).to be > 0 and eq @core_versions.size
        versions.each do |version|
          expect(version.app.name).to eq "main"
          expect(version.is_extension?).to eq false
          expect(@extension_versions).not_to include version
        end
      end
    end

    describe "extension_versions" do
      before do
        main_app = @base.add_app "main"
        @core_versions = []
        @core_versions << @base.add_version("0.0.2")
        @core_versions << @base.add_version("0.0.2.1")
        @core_versions << @base.add_version("0.0.2.2")
        @extension_versions = []
        @extension_versions << @base.add_extension_version("0.0.2", "extension_name")
        @extension_versions << @base.add_extension_version("0.1.2", "extension_name")
        @extension_versions << @base.add_extension_version("0.1.2.1", "extension_name")
        @extension_versions << @base.add_extension_version("1.0.2.2", "extension_name")
      end
      it "return array of version which belongs to non-main app" do
        versions = @base.extension_versions
        expect(versions).to be_an Array
        expect(versions.size).to be > 0 and eq @extension_versions.size
        versions.each do |version|
          expect(version.app.name).not_to eq "main"
          expect(version.is_extension?).to eq true
          expect(@core_versions).not_to include version
        end
      end
    end

    describe "apis_group_by_resource" do
      context "call without version" do
        it "return correct hash of resource_name as key and apis as values" do
          @base.send(:set_default_value)
          class ApiGroupByResource_ApiDoc < ApiDoc
            controller_name :users
            api :show, ""
            api :update, ""
          end
          class ApiGroupByResource_2ApiDoc < ApiDoc
            controller_name :products
            api :show, ""
            api :update, ""
            api :destroy, ''
          end
          class ApiGroupByResource_3ApiDoc < ApiDoc
            controller_name :users
            version '0.0.1'
            api :index, ""
            api :show, ""
            api :update, ""
          end
          class ApiGroupByResource_4ApiDoc < ApiDoc
            controller_name :products
            version '0.0.1'
            api :index, ""
            api :show, ""
            api :update, ""
            api :destroy, ''
          end
          api_hash = @base.apis_group_by_resource
          expect(api_hash).to be_an Hash
          expect(api_hash.keys.sort).to eq ['users', 'products'].sort
          api_hash.each do |key, value|
            expect(value).to be_an Array
            expect(value.size).to eq (key == 'users' ? 2 : 3)
            value.each do |api|
              expect(api).to be_an OneboxApiDoc::Api
              expect(api.resource.name).to eq key
              expect(api.version_id).to eq @base.default_version.object_id
            end
          end
        end
      end
      context "call with version" do
        it "return correct hash of resource_name as key and apis as values" do
          @base.send(:set_default_value)
          class ApiGroupByResource_5ApiDoc < ApiDoc
            controller_name :users
            api :show, ""
            api :update, ""
          end
          class ApiGroupByResource_6ApiDoc < ApiDoc
            controller_name :products
            api :show, ""
            api :update, ""
            api :destroy, ''
          end
          class ApiGroupByResource_7ApiDoc < ApiDoc
            controller_name :users
            version '0.0.1'
            api :show, ""
          end
          class ApiGroupByResource_8ApiDoc < ApiDoc
            controller_name :products
            version '0.0.1'
            api :index, ""
            api :show, ""
            api :update, ""
            api :destroy, ''
          end
          version = @base.get_version '0.0.1'
          api_hash = @base.apis_group_by_resource version
          expect(api_hash).to be_an Hash
          expect(api_hash.keys.sort).to eq ['users', 'products'].sort
          api_hash.each do |key, value|
            expect(value).to be_an Array
            expect(value.size).to eq (key == 'users' ? 1 : 4)
            value.each do |api|
              expect(api).to be_an OneboxApiDoc::Api
              expect(api.resource.name).to eq key
              expect(api.version_id).to eq version.object_id
            end
          end
        end
      end
    end

    describe "get api" do
      before do
        @base.reload_document
      end
      context 'call with action' do
        it 'return correct api object' do
          api = @base.get_api(version: OneboxApiDoc::Engine.default_version, resource_name: :products, action_name: :index)
          expect(api).to be_an OneboxApiDoc::Api
          expect(api.action).to eq 'index'
          expect(api.resource.name).to eq 'products'
          expect(api.version).to eq @base.default_version
        end
        it 'return nil if version does not exist' do
          api = @base.get_api(version: 'fake version', resource_name: :products, action_name: :index)
          expect(api).to eq nil
        end
        it 'return nil if resource does not exist' do
          api = @base.get_api(version: @base.default_version.name, resource_name: :fake_resource, action_name: :index)
          expect(api).to eq nil
        end
        it 'return nil if action does not exist' do
          api = @base.get_api(version: @base.default_version.name, resource_name: :products, action_name: :fake_action)
          expect(api).to eq nil
        end
      end
      context 'call without action' do
        it 'return correct array of apis' do
          apis = @base.get_api(version: OneboxApiDoc::Engine.default_version, resource_name: :products)
          expect(apis).to be_an Array
          expect(apis.size).to be > 0
          apis.each do |api|
            expect(api).to be_an OneboxApiDoc::Api
            expect(api.resource.name).to eq 'products'
            expect(api.version).to eq @base.default_version
          end
        end
        it 'return blank array if version does not exist' do
          apis = @base.get_api(version: 'fake version', resource_name: :products)
          expect(apis).to eq []
        end
        it 'return blank array if resource does not exist' do
          apis = @base.get_api(version: @base.default_version.name, resource_name: :fake_resource)
          expect(apis).to eq []
        end
      end
    end

    describe "get_version" do
      before do
        @base.add_version "0.0.1"
      end
      it "return correct version" do
        version = @base.get_version "0.0.1"
        expect(version).not_to eq nil
        expect(version).to be_a OneboxApiDoc::Version
        expect(version.name).to eq "0.0.1"
      end
      it "return nil if version not found" do
        version = @base.get_version "0.0.9"
        expect(version).to eq nil
      end
    end

    describe "get_resource" do
      before do
        @base.add_resource :new_resource
      end
      it "return correct resource" do
        resource = @base.get_resource :new_resource
        expect(resource).not_to eq nil
        expect(resource).to be_a OneboxApiDoc::Resource
        expect(resource.name).to eq "new_resource"
      end
      it "return nil if resource not found" do
        resource = @base.get_resource :fake_resource
        expect(resource).to eq nil
      end
    end

    describe "get_doc" do
      before do
        @version = @base.default_version
        @base.add_doc @version.object_id
      end
      it "return correct doc" do
        doc = @base.get_doc @version.name
        expect(doc).not_to eq nil
        expect(doc).to be_a OneboxApiDoc::Doc
        expect(doc.version).to eq @version
      end
      it "return nil if version not found" do
        doc = @base.get_doc :fake_version
        expect(doc).to eq nil
      end
    end

    describe "get_app" do
      before do
        @base.add_app :new_app
      end
      it "return correct app" do
        app = @base.get_app :new_app
        expect(app).not_to eq nil
        expect(app).to be_a OneboxApiDoc::App
        expect(app.name).to eq "new_app"
      end
      it "return nil if app not found" do
        app = @base.get_app :fake_app
        expect(app).to eq nil
      end
    end

    describe "add_resource" do
      before do
        @base.resources = []
      end
      it "add resource to array resources" do
        expect{ @base.add_resource :new_resource }.to change(@base.resources, :size).by 1
      end
      it "does not add array resource to resources if resource with the same name already exist" do
        @base.add_resource :new_resource
        expect{ @base.add_resource :new_resource }.not_to change(@base.resources, :size)
      end
      it "return correct resource" do
        resource = @base.add_resource :new_resource
        expect(resource).to be_an OneboxApiDoc::Resource
        expect(resource.name).to eq "new_resource"
      end
    end

    describe "add_version" do
      it "add version to array versions" do
        expect{ @base.add_version "1.2" }.to change(@base.versions, :size).by 1
      end
      it "does not add version to array versions if version with the same name already exist" do
        @base.add_version "1.2"
        expect{ @base.add_version "1.2" }.not_to change(@base.versions, :size)
      end
      it "return correct version" do
        version = @base.add_version '1.2'
        expect(version).to be_an OneboxApiDoc::Version
        expect(version.name).to eq "1.2"
        expect(version.is_extension?).to eq false
      end
    end

    describe "add_extension_version" do
      before do
        @base.send(:set_default_value)
      end
      it "add version to array versions" do
        expect{ @base.add_extension_version "1.2", :extension_name }.to change(@base.versions, :size).by 1
      end
      it "add extension app" do
        expect{ @base.add_extension_version "1.2", :extension_name }.to change(@base.apps, :size).by 1
      end
      it "does not add extension app if it already exist" do
        @base.add_app :extension_name
        expect{ @base.add_extension_version "1.2", :extension_name }.not_to change(@base.apps, :size)
      end
      it "does not add version to array versions if version with the same name already exist" do
        @base.add_extension_version "1.2", :extension_name
        expect{ @base.add_extension_version "1.2", :extension_name }.not_to change(@base.versions, :size)
      end
      it "return correct extension version" do
        version = @base.add_extension_version "1.2", :extension_name
        expect(version).to be_an OneboxApiDoc::Version
        expect(version.name).to eq "1.2"
        expect(version.app.name).to eq "extension_name"
        expect(version.is_extension?).to eq true
      end
    end

    describe "add_app" do
      it "add app to array apps" do
        expect{ @base.add_app :new_app }.to change(@base.apps, :size).by 1
      end
      it "does not add app to array apps if app with the same name already exist" do
        @base.add_app :new_app
        expect{ @base.add_app :new_app }.not_to change(@base.apps, :size)
      end
      it "return correct app" do
        app = @base.add_app :new_app
        expect(app).to be_an OneboxApiDoc::App
        expect(app.name).to eq "new_app"
      end
    end

    describe "add_doc" do
      before do
        @base.send(:set_default_value)
        @version = @base.default_version
      end
      it "add doc to array docs" do
        expect{ @base.add_doc @version.object_id }.to change(@base.docs, :size).by 1
      end
      it "does not add doc to array docs if doc with the same version already exist" do
        @base.add_doc @version.object_id
        expect{ @base.add_doc @version.object_id }.not_to change(@base.docs, :size)
      end
      it "return correct doc" do
        doc = @base.add_doc @version.object_id
        expect(doc).to be_an OneboxApiDoc::Doc
        expect(doc.version).to eq @version
      end
    end

  end
end