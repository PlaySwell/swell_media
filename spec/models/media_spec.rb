require 'spec_helper'

describe Media do
	it "is invalid without a title" do
		expect( Media.create(title: nil) ).to have(1).errors_on(:title)
	end

	it "returns a url" do
		media = Media.create(title: 'my test media')

		expect( media.url( domain: 'test.com' ) ).to eq 'http://test.com/my-test-media'
		expect( media.url( domain: 'test.com', ref: 'test' ) ).to eq 'http://test.com/my-test-media?ref=test'
	end


end