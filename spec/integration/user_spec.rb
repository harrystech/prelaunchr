require 'rails_helper'

describe "users", type: :request do
  describe 'campaign ended' do
    before(:each) do
      Rails.application.config.ended = true
    end

    after(:each) do
      Rails.application.config.ended = false
    end

    it 'should display campaign ended message when campaign has ended' do
      get '/'
      expect(response).to render_template(:partial => "_campaign_ended")
    end
  end
end