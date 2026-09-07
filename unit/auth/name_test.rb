require 'test_helper'
require 'fog/openstack/auth/name'

describe Fog::OpenStack::Auth::Name do
  describe 'creates' do
    it 'when id and name are provided' do
      name = Fog::OpenStack::Auth::Name.new('default', 'Default')
      _(name.id).must_equal 'default'
      _(name.name).must_equal 'Default'
    end

    it 'when id is null' do
      name = Fog::OpenStack::Auth::Name.new(nil, 'Default')
      _(name.id).must_be_nil
      _(name.name).must_equal 'Default'
    end

    it 'when name is null' do
      name = Fog::OpenStack::Auth::Name.new('default', nil)
      _(name.id).must_equal 'default'
      _(name.name).must_be_nil
    end

    it 'when both id and name is null' do
      name = Fog::OpenStack::Auth::Name.new(nil, nil)
      _(name.name).must_be_nil
    end
  end

  describe '#to_h' do
    it 'returns the hash of provided attribute' do
      name = Fog::OpenStack::Auth::Name.new('default', 'Default')
      _(name.to_h(:id)).must_equal(:id => 'default')
      _(name.to_h(:name)).must_equal(:name => 'Default')
    end
  end
end

describe Fog::OpenStack::Auth::User do
  describe '#password' do
    it 'set/get password' do
      user = Fog::OpenStack::Auth::User.new('user_id', 'User')
      user.password = 'secret'
      _(user.identity).must_equal(:user => {:id => 'user_id', :password => 'secret'})
    end
  end

  describe '#identity' do
    describe 'succesful' do
      it "with user id and user name" do
        user = Fog::OpenStack::Auth::User.new('user_id', 'User')
        user.password = 'secret'
        _(user.identity).must_equal(:user => {:id => 'user_id', :password => 'secret'})
      end

      it 'with user name and user domain name' do
        user = Fog::OpenStack::Auth::User.new(nil, 'User')
        user.password = 'secret'
        user.domain = Fog::OpenStack::Auth::Name.new('default', nil)
        _(user.identity).must_equal(:user => {:name => 'User', :domain => {:id => 'default'}, :password => 'secret'})
      end

      it 'with user name and domain name' do
        user = Fog::OpenStack::Auth::User.new(nil, 'User')
        user.password = 'secret'
        user.domain = Fog::OpenStack::Auth::Name.new(nil, 'Default')
        _(user.identity).must_equal(:user => {:name => 'User', :domain => {:name => 'Default'}, :password => 'secret'})
      end
    end

    describe 'raises an error' do
      it 'raises an error when password is missing' do
        _(proc do
          user = Fog::OpenStack::Auth::User.new('user_id', 'User')
          user.identity
        end).must_raise Fog::OpenStack::Auth::CredentialsError
      end

      it 'with only user name and no domain' do
        _(proc do
          user = Fog::OpenStack::Auth::User.new(nil, 'User')
          user.identity
        end).must_raise Fog::OpenStack::Auth::CredentialsError
      end
    end
  end
end

describe Fog::OpenStack::Auth::ProjectScope do
  describe '#identity' do
    it "when id is provided it doesn't require domain" do
      project = Fog::OpenStack::Auth::ProjectScope.new('project_id', 'Project')
      _(project.identity).must_equal(:project => {:id => 'project_id'})
    end

    it 'when id is nul and name is provided it uses domain id' do
      project = Fog::OpenStack::Auth::ProjectScope.new(nil, 'Project')
      project.domain = Fog::OpenStack::Auth::Name.new('default', nil)
      _(project.identity).must_equal(:project => {:name => 'Project', :domain => {:id => 'default'}})
    end

    it 'when id is nul and name is provided it uses domain name' do
      project = Fog::OpenStack::Auth::ProjectScope.new(nil, 'Project')
      project.domain = Fog::OpenStack::Auth::Name.new(nil, 'Default')
      _(project.identity).must_equal(:project => {:name => 'Project', :domain => {:name => 'Default'}})
    end

    it 'raises an error with no project id and no domain are provided' do
      _(proc do
        project = Fog::OpenStack::Auth::ProjectScope.new(nil, 'Project')
        project.identity
      end).must_raise Fog::OpenStack::Auth::CredentialsError
    end
  end
end
