module Cybersourcery
  class MerchantDataSerializer
    attr_reader :start_count

    def initialize(start_count = 1)
      @start_count = start_count
    end

    def serialize(merchant_data)
      scanned_data = merchant_data.to_json.scan(/.{1,100}/)
      serialized_data = {}

      merchant_data.each_with_index do |item, index|
        count = index + @start_count

        if count < 1 || count > 100
          raise Cybersourcery::CybersourceryError, "The supported merchant_defined_data range is 1 to 100. #{count} is out of range."
        end

        serialized_data["merchant_defined_data#{count}".to_sym] = item.to_json
      end

      serialized_data
    end

    def deserialize(params)
      merchant_data = params.select { |k,v| k =~ /^req_merchant_defined_data/ }.symbolize_keys
      merchant_data_string = {}

      # it's important to reassemble the data in the right order!
      merchant_data.length.times do |i|
        merchant_data_string.merge!(JSON.parse(merchant_data["req_merchant_defined_data#{i+1}".to_sym]))
      end

      merchant_data_string
    end
  end
end
