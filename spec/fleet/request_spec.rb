require 'spec_helper'

describe Fleet::Request do

  subject { Fleet::Client.new }

  let(:path) { '/path' }

  let(:request) do
    double(:request,
      options: {},
      headers: {},
      params: {},
      'headers=' => nil,
      'path=' => nil)
  end

  let(:response) do
    double(:response, body: 'foo')
  end

  let(:connection) { double(:connection) }

  before do
    allow(connection).to receive(:send).and_yield(request).and_return(response)
    allow(subject).to receive(:connection).and_return(connection)
  end

  [:get, :delete, :head, :put, :post].each do |method|

    context "##{method}" do

      it 'sets the path' do
        expect(request).to receive(:path=).with(path)
        subject.send(method, path)
      end

      it 'sets the headers' do
        headers = { foo: :bar }
        expect(request).to receive(:headers=).with(hash_including(headers))
        subject.send(method, path, {}, headers)
      end

      it 'returns the response body' do
        expect(subject.send(method, path)).to eql(response.body)
      end

      context 'when a Faraday::Error::ConnectionFailed error is raised' do

        before do
          allow(connection).to receive(:send)
            .and_raise(Faraday::Error::ConnectionFailed, 'oops')
        end

        it 'raises a Fleet::ConnectionError' do
          expect { subject.send(method, path) }.to raise_error(Fleet::ConnectionError, 'oops')
        end
      end
    end
  end

  [:get, :delete, :head].each do |method|

    context "##{method}" do

      context 'when options provided' do

        it 'sets options on the request' do
          options = { a: :b }
          expect(request).to receive(:params=).with(options)
          subject.send(method, path, options)
        end
      end

      context 'when no options provided' do

        it 'does not set options on the request' do
          expect(request).to_not receive(:params=)
          subject.send(method, path)
        end
      end
    end
  end

  [:put, :post].each do |method|

    context "##{method}" do

      context 'when options provided' do

        it 'sets options on the request' do
          options = { a: :b }
          expect(request).to receive(:body=).with(options)
          subject.send(method, path, options)
        end
      end

      context 'when no options provided' do

        it 'does not set options on the request' do
          expect(request).to_not receive(:body=)
          subject.send(method, path)
        end
      end

      context 'when querystring AND body provided' do
        let(:options) { { querystring: { a: :b }, body: { c: :d } } }

        before do
          allow(request).to receive(:params=)
          allow(request).to receive(:body=)
        end

        it 'sets the querystring as request params' do
          expect(request).to receive(:params=).with(options[:querystring])
          subject.send(method, path, options)
        end

        it 'sets the body as request body' do
          expect(request).to receive(:body=).with(options[:body])
          subject.send(method, path, options)
        end
      end

    end
  end

end
