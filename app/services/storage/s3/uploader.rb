require 'aws-sdk-s3'

module Storage
  module S3
    class Uploader
      def initialize(key:, bucket:)
        @key = key
        @bucket = bucket
      end

      def upload(file_data:)
        res = client.put_object(bucket: bucket, key: key, body: file_data)
        Rails.logger.info(res)
        res
      end

      def exists?
        begin
          client.head_object(bucket: bucket, key: key)
          true
        rescue Aws::S3::Errors::NotFound
          false
        end
      end

      def purge_from_s3!
        client.delete_object(bucket: bucket, key: key)
      end

      def created_at
        meta_data = client.head_object(bucket: bucket, key: key)
        meta_data.last_modified
      end

      def s3_url
        signer = Aws::S3::Presigner.new(client: client)
        signer.presigned_url(:get_object, bucket: bucket, key: key)
      end

      private

      attr_accessor :key, :bucket

      REGION = 'eu-west-2'.freeze

      def client
        @client ||= Aws::S3::Client.new(region: REGION)
      end
    end
  end
end
