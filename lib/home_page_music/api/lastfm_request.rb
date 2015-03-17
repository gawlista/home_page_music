module HomePageMusic
  module Api
    class LastfmRequest
      attr_reader :response
      
      def initialize(resource, method, error_message_reqexp, params = {})
        lastfm = ::Lastfm.new(
          Setting['home_page.apis.providers.lastfm.key'],
          Setting['home_page.apis.providers.lastfm.secret']
        )
        @response = nil
        raise_if_response_is_just_nil = params.delete(:raise_if_response_is_just_nil)
        raise_parse_exception = params.delete(:raise_parse_exception)
        i = 1
          
        3.times do
          begin
            @response = lastfm.send(resource).send(method, params)
            
            raise 'last.fm response is just nil without exceptions' if @response.nil? && raise_if_response_is_just_nil
            
            break
          rescue Timeout::Error, EOFError => e 
            puts "lastfm: #{e.class.name} for ##{i} time"
            sleep 60 
          rescue ArgumentError => e
            if e.message.match('File does not exist')
              puts "lastfm: 'File does not exist' sleep 60 seconds for ##{i} time ..."
              sleep 60
            else
              raise e
            end
          rescue ::Lastfm::ApiError => e
            if error_message_reqexp.nil? || e.message.match(error_message_reqexp).nil?
              if e.message.match(/Operation failed - Something else went wrong/)
                puts "lastfm: operation failed - something else went wrong for ##{i} time ..."
                sleep 60
              else
                raise e
              end
            end
          rescue REXML::ParseException => e
            raise e if raise_parse_exception
          end
          
          i += 1
        end
      end
    end
  end
end