require 'spec_helper'

describe SwellMedia::Media do
	it "is invalid without a title" do
		expect( SwellMedia::Media.create(title: nil) ).to have(1).errors_on(:title)
	end

	it "returns a url" do
		media = SwellMedia::Media.create(title: 'my test media')

		expect( media.url( domain: 'test.com' ) ).to eq 'http://test.com/my-test-media'
		expect( media.url( domain: 'test.com', ref: 'test' ) ).to eq 'http://test.com/my-test-media?ref=test'
	end

	it "returns active" do
		media_a = SwellMedia::Media.create(title: 'Active 1', status: :active, availability: :public, publish_at: Time.zone.now )
		media_b = SwellMedia::Media.create(title: 'Active 2', status: :active, availability: :public, publish_at: Time.zone.now )
		media_c = SwellMedia::Media.create(title: 'Future 1', status: :active, availability: :public, publish_at: 1.day.from_now )
		media_d = SwellMedia::Media.create(title: 'Future 2', status: :active, availability: :public, publish_at: 1.minutes.from_now )
		media_e = SwellMedia::Media.create(title: 'Disabled 1', status: :disabled, availability: :public, publish_at: Time.zone.now )
		media_f = SwellMedia::Media.create(title: 'Disabled 2', status: :disabled, availability: :public, publish_at: 1.minutes.from_now )
		media_g = SwellMedia::Media.create(title: 'Draft 1', status: :active, availability: :draft, publish_at: Time.zone.now )
		media_h = SwellMedia::Media.create(title: 'Draft 2', status: :disabled, availability: :draft, publish_at: 1.minutes.from_now )
		media_i = SwellMedia::Media.create(title: 'Draft 3', status: :active, availability: :draft, publish_at: 1.minutes.from_now )

		expect(SwellMedia::Media.active.count).to eq 2
		expect(SwellMedia::Media.active.order(:id)).to eq [media_a, media_b]
	end

	it "author" do
		media_a = SwellMedia::Media.create(title: 'Active 1', properties: { 'author_name' => 'Johnny Appleseed' } )
		expect(media_a.author).to eq 'Johnny Appleseed'

		media_b = SwellMedia::Media.create(title: 'Active 1', properties: nil )
		expect(media_b.author).to eq ''
	end


end