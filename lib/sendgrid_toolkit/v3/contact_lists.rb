module SendgridToolkit
  module V3
    class ContactLists < SendgridToolkit::V3::MarketingCampaignsClient
      def add(options = {})
        response = api_post('lists', options)
        fail ContactListsError if response.is_a?(Hash) && response.key?('errors')
        response
      end

      def get(list_id = nil)
        action_name = 'lists' + (list_id ? "/#{list_id}" : '')
        response = api_get(action_name)
        fail ContactListsError if response.is_a?(Hash) && response.key?('errors')
        response
      end

      def recipients(list_id, options = {})
        fail NoContactListIdSpecified unless list_id
        response = api_get("lists/#{list_id}/recipients", options)
        fail ContactListsError if response.is_a?(Hash) && response.key?('errors')
        response
      end

      def add_recipient(list_id, recipient_id)
        fail NoContactListIdSpecified unless list_id
        response = api_post("lists/#{list_id}/recipients/#{recipient_id}")
        fail ContactListsError if response.is_a?(Hash) && response.key?('errors')
        response
      end

      def delete_recipient(list_id, recipient_id)
        fail NoContactListIdSpecified unless list_id
        response = api_delete("lists/#{list_id}/recipients/#{recipient_id}")
        fail ContactListsError if response.is_a?(Hash) && response.key?('errors')
        response
      end

      def add_recipients(list_id, recipient_ids)
        fail NoContactListIdSpecified unless list_id
        response = api_post("lists/#{list_id}/recipients", recipient_ids)
        fail ContactListsError if response.is_a?(Hash) && response.key?('errors')
        response
      end

      def delete(list_id)
        fail NoContactListIdSpecified unless list_id

        response = api_delete("lists/#{list_id}")
        fail ContactListsError if response.is_a?(Hash) && response.key?('errors')
        response
      end
    end
  end
end
