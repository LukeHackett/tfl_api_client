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

require_relative '../spec_helper'

describe '/CycleSuperhighway Integration', type: :feature do
  let!(:authorised_cycle)   { authorised_client.cycle }
  let!(:unauthorised_cycle) { unauthorised_client.cycle }

  describe '#superhighways' do
    context 'with an authorised client' do
      it 'should return all cycle superhighways' do
        VCR.use_cassette('cycle/authorised_client_superhighways') do
          locations = authorised_cycle.superhighways
          expect(locations).to be_kind_of(Array)
          expect(locations).to_not be_empty
        end
      end
    end

    context 'with an unauthorised client' do
      it 'should raise an exception' do
        VCR.use_cassette('cycle/unauthorised_client_superhighways') do
          expect {
            unauthorised_cycle.superhighways
          }.to raise_error(TflApi::Exceptions::ApiException)
        end
      end
    end
  end

  describe '#superhighway' do
    let(:highway_id) { 'RMP-006' }

    context 'with an authorised client' do
      it "should return the given superhighway's details" do
        VCR.use_cassette('cycle/authorised_client_superhighway') do
          superhighway = authorised_cycle.superhighway(highway_id)
          expect(superhighway).to be_kind_of(Hash)
          expect(superhighway['id']).to eq(highway_id)
          expect(superhighway['labelShort']).to eq('CSNS')
        end
      end
    end

    context 'with an unauthorised client' do
      it 'should raise an exception' do
        VCR.use_cassette('cycle/unauthorised_client_superhighway') do
          expect {
            unauthorised_cycle.superhighway(highway_id)
          }.to raise_error(TflApi::Exceptions::ApiException)
        end
      end
    end
  end

end