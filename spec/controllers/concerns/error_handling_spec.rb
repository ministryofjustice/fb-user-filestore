require 'rails_helper'

RSpec.describe ApplicationController do
  context 'when there is an error' do
    controller do
      include Concerns::ErrorHandling

      def index
        raise :foo
      end
    end

    it 'calls sentry with exception' do
      expect(Sentry).to receive(:capture_exception)
      get :index
    end
  end

  context 'when there is no error' do
    controller do
      include Concerns::ErrorHandling

      def index
      end
    end

    it 'does not call sentry' do
      expect(Sentry).to_not receive(:capture_exception)
      get :index
    end
  end
end
