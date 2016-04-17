#
# Copyright (c) 2015 - 2016 Luke Hackett
#
# MIT License
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#


module TflApi
  class Client
    # This class communicates with the TFL "/CycleSuperhighway" API to obtain
    # details about the cycle superhighways based upon their IDs.
    #
    class Cycle

      # Initialize the Cycle object and store the reference to Client object
      #
      # @param client [Client] the client object
      #
      # @return [Cycle] the Cycle object
      #
      def initialize(client)
        @client = client
      end

      # Returns all Cycle Superhighway locations known by the TFL service
      #
      # @return [Array] An array of hashes containing all Cycle Superhighways
      #                 and their details
      #
      def superhighways
        @client.get('/CycleSuperhighway')
      end

      # Returns the all details known by the TFL service for the given
      # Cycle Superhighway id.
      #
      # @param id [String] the TFL Cycle Superhighway id
      #
      # @return [hash] A hash containing the details of the given Cycle Superhighway
      #
      def superhighway(id)
        @client.get("/CycleSuperhighway/#{id}")
      end

    end
  end
end
