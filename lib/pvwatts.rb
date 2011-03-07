require 'rubygems'
require 'savon'

# Wrapper around the http://www.nrel.gov/rredc/pvwatts/ web service API.
# Calculates the Performance of a Grid-Connected PV System. 
# Use of the Pvwatts web service is restricted to authorized users. 
# For information on obtaining authorization, contact bill_marion@nrel.gov
#
# @see http://www.nrel.gov/rredc/pvwatts/
#
# @author Matt Aimonetti for http://solaruniverse.com
#
class Pvwatts
  
  Savon::Request.log = false
  DEFAULT_DERATE = 0.82
  
  attr_reader :api_key
  
  # Create an instance of the API wrapper.
  #
  # @param [String] api_key The Pvwatts API key provided by bill_marion@nrel.gov
  #
  def initialize(api_key)
    @api_key = api_key
  end
  
  # Calculate the estimated yearly production based on passed options.
  #
  # @param [Hash] opts
  # @option opts [String, Float] :latitude Latitude coordinate of the location.
  # @option opts [String, Float] :longitude Longitude coordinate of the location.
  # @option opts [String, Float] :dc_rating
  # @option opts [String, Integer] :tilt
  # @option opts [String, Integer] :orientation Orientation or azimuth value.
  # @option opts [String, Integer] :shading A percentage value between 0 and 100.
  #
  # @return [Hash] A hash with the yearly production with a key for each month and a 'year' key to represent the yearly value.
  #
  def yearly_production(opts={})
    Rails.logger.debug("pvwatts yearly prod called") if Object.const_defined?(:Rails)
    keys = opts.keys 
    client = Savon::Client.new("http://pvwatts.nrel.gov/PVWATTS.asmx?WSDL")
    @latitude, @longitude = [opts[:latitude], opts[:longitude]]
    @dc_rating, @tilt, @orientation = opts[:dc_rating], opts[:tilt], opts[:orientation]
    @shading = opts[:shading]
    if @latitude.nil? || @longitude.nil? || @dc_rating.nil? || @tilt.nil? || @orientation.nil? || @shading.nil?
      raise ArgumentError, "passed -> latitude: #{@latitude}, longitude: #{@longitude}, dc_rating: #{@dc_rating}\
      tilt: #{@tilt} orientation: #{@orientation} shading: #{@shading}"
    end
    req = prep_request(@latitude, @longitude, @dc_rating, @tilt, @orientation, @shading)
    
    response = client.get_pvwatts{|soap| soap.input = "GetPVWATTS"; soap.body = req }
    rdata = response.to_hash
    if rdata[:get_pvwatts_response] && rdata[:get_pvwatts_response][:get_pvwatts_result] && rdata[:get_pvwatts_response][:get_pvwatts_result][:pvwatt_sinfo]
      @production_data = {}
      @pvwatt_info = rdata[:get_pvwatts_response][:get_pvwatts_result][:pvwatt_sinfo].compact
      @pvwatt_info.each do |el| 
        if el.respond_to?(:has_key?) && el.has_key?(:month)
          @production_data[el[:month].downcase] = el[:a_cenergy].to_i
        end
      end
    else
      raise 'Problem with the pvwatts response'
    end
    @production_data
  end
  
  private
  
  def prep_request(latitude, longitude, dc_rating, tilt, orientation, shading)
    Rails.logger.debug "calling pvwatts with: latitude: #{latitude}, longitude: #{longitude}, dc_rating: #{dc_rating}, tilt: #{tilt}, orientation: #{orientation}, shading: #{shading}" if Object.const_defined?(:Rails)
    shading = (shading == 0 ? 1 : shading / 100)
    { 'wsdl:key'        => api_key,
      'wsdl:latitude'   => latitude,
      'wsdl:longitude'  => longitude,
      'wsdl:locationID' => '', 
      'wsdl:DCrating'   => dc_rating, 
      # I will have to give this some thought, but .8 is a better number for now– it has todo with the shading and efficiency of inverters – we may need to pass efficiency data to get an accurate number along with the shading data (ie. how shaded the location is))
      'wsdl:derate'     => (DEFAULT_DERATE * shading),
      'wsdl:cost'       => 0.0,
      'wsdl:mode'       => 0,
      'wsdl:tilt'       => tilt,
      'wsdl:azimuth'    => orientation,
      'wsdl:inoct'      => 45.0,
      'wsdl:pwrdgr'     => -0.005
    }
  end
  
end