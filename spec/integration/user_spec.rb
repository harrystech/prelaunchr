require 'rails_helper'

describe "users", type: :request do
  describe 'campaign ended' do
    before do
      allow(Rails.application.config).to receive(:ended) { true }
    end

    it 'should display campaign ended message when campaign has ended' do
      get '/'
      expect(response).to render_template(:partial => "_campaign_ended")
    end
  end
end