module SendgridToolkit
  module V3
    class Contacts < SendgridToolkit::V3::MarketingCampaignsClient
      def add(recipients)
        response = api_post('recipients', recipients)
        fail ContactsError.new(response['errors']) if response.is_a?(Hash) && response.key?('errors')
        response
      end

      def update(options)
        response = api_patch('recipients', recipients)
        fail ContactsError.new(response['errors']) if response.is_a?(Hash) && response.key?('errors')
        response
      end

      def get(recipient_id = nil, options = {})
        if recipient_id.is_a?(Hash) && options == {}
          options = recipient_id
          recipient_id = nil
        end
        action_name = 'recipients' + (recipient_id ? "/#{recipient_id}" : '')
        response = api_get("action_name", options)
        fail ContactsError.new(response['errors']) if response.is_a?(Hash) && response.key?('errors')
        response
      end

      def delete(recipient_ids)
        fail NoContactIdSpecified unless recipient_ids

        response = api_delete("recipients", recipient_ids)
        fail ContactsError.new(response['errors']) if response.is_a?(Hash) && response.key?('errors')
        response
      end
    end
  end
end
