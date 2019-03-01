require 'rails_helper'
require 'base64'
require 'pry'

describe 'FileUpload API', type: :request do
  describe 'a POST /service/{service_slug}/{user_id} request' do
    before do
      headers = { 'CONTENT_TYPE' => 'application/json' }
      post '/service/service-slug/user/user-id', :params => json.to_json, :headers => headers
    end

    after do
      File.delete('files/result') if File.exist?('files/result')
    end

    describe 'upload with JSON payload' do
      let(:file) { file_fixture('hello_world.txt').read }
      let(:encoded_file) { Base64.encode64(file) }
      let(:json) { json_format(encoded_file) }

      it 'has status 200' do
        expect(response).to have_http_status(200)
      end

      it 'saves the decoded data to a local file' do
        decoded_data = File.open('files/result').read
        expect(file).to eq(decoded_data)
      end

      it 'renders success JSON' do
        expect(JSON.parse(response.body)).to eq({ name: 'success' }.as_json)
      end
    end

    describe 'file exceeds max file size' do
      let(:file) { file_fixture('sample.txt').read }
      let(:encoded_file) { Base64.encode64(file) }
      let(:json) { json_format(encoded_file) }

      context 'returns error if file size is too large' do
        it 'has status 400' do
          expect(response).to have_http_status(400)
        end

        it 'returns JSON with invalid.too-large content' do
          result = JSON.parse(response.body)
          expect(result['name']).to eq('invalid.too-large')
        end
      end
    end

    describe 'checking file types' do
      context 'accepts supported mime types' do
        describe 'plain text format' do
          let(:file) { file_fixture('hello_world.txt').read }
          let(:encoded_file) { Base64.encode64(file) }
          let(:json) { json_format(encoded_file) }

          it 'has status 200' do
            expect(response).to have_http_status(200)
          end
        end

        describe 'word document format' do
          let(:file) { file_fixture('random.docx').read }
          let(:encoded_file) { Base64.encode64(file) }
          let(:json) { json_format(encoded_file) }

          it 'has status 200' do
            expect(response).to have_http_status(200)
          end
        end

        describe 'excel spreadsheet format' do
          let(:file) { file_fixture('spreadsheet.xlsx').read }
          let(:encoded_file) { Base64.encode64(file) }
          let(:json) { json_format(encoded_file) }

          it 'has status 400' do
            expect(response).to have_http_status(400)
          end
        end

        describe 'open document format' do
          let(:file) { file_fixture('random.odt').read }
          let(:encoded_file) { Base64.encode64(file) }
          let(:json) { json_format(encoded_file) }

          it 'has status 200' do
            expect(response).to have_http_status(200)
          end
        end

        describe 'pdf format' do
          let(:file) { file_fixture('document.pdf').read }
          let(:encoded_file) { Base64.encode64(file) }
          let(:json) { json_format(encoded_file) }

          it 'has status 200' do
            expect(response).to have_http_status(200)
          end
        end

        describe 'jpeg format' do
          let(:file) { file_fixture('image.jpg').read }
          let(:encoded_file) { Base64.encode64(file) }
          let(:json) { json_format(encoded_file) }

          it 'has status 200' do
            expect(response).to have_http_status(200)
          end
        end

        describe 'png format' do
          let(:file) { file_fixture('image.png').read }
          let(:encoded_file) { Base64.encode64(file) }
          let(:json) { json_format(encoded_file) }

          it 'has status 200' do
            expect(response).to have_http_status(200)
          end
        end
      end

      context 'Mime types that are not supported' do
        describe 'bmp format' do
          let(:file) { file_fixture('bitmap.bmp').read }
          let(:encoded_file) { Base64.encode64(file) }
          let(:json) { json_format(encoded_file) }

          it 'has status 400' do
            expect(response).to have_http_status(400)
          end

          it 'returns JSON with invalid type content' do
            result = JSON.parse(response.body)
            expect(result['name']).to eq('invalid type')
          end
        end

        describe 'html format' do
          let(:file) { file_fixture('hello.html').read }
          let(:encoded_file) { Base64.encode64(file) }
          let(:json) { json_format(encoded_file) }

          it 'has status 400' do
            expect(response).to have_http_status(400)
          end

          it 'returns JSON with invalid type content' do
            result = JSON.parse(response.body)
            expect(result['name']).to eq('invalid type')
          end
        end
      end
    end
  end

  describe 'generate fingerprint' do
    let(:file) { file_fixture('document.pdf') }
    let(:regex) { /\A[0-9a-f]{32,128}\z/i }
    let(:fingerprint) { UserFileController.fingerprint(file) }
    it 'returns a SHA1 checksum' do
      expect(fingerprint).to eq(Digest::SHA1.file(file).to_s)
    end

    it 'is 40 characters long' do
      expect(fingerprint.length).to eq(40)
    end

    it 'is a valid checksum' do
      expect(regex.match?(fingerprint)).to eq(true)
    end
  end

  def json_format(encoded_file)
    {
      "iat": '{timestamp}',
      "encrypted_user_id_and_token": '{userId+userToken encrypted via AES-256 with the serviceToken as the key}',
      "file": encoded_file,
      "policy": {
        "allowed_types": %w[
          text/plain
          application/vnd.openxmlformats-officedocument.wordprocessingml.document
          application/msword
          application/vnd.oasis.opendocument.text
          application/pdf
          image/jpeg
          image/png
          application/vnd.ms-excel
        ],
        "max_size": '10240',
        "expires": '28d'
      }
    }
  end
end
