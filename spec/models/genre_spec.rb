# spec/models/genre_spec.rb
require 'rails_helper'

RSpec.describe Genre, type: :model do
  #create a genre
  let(:genre) { Genre.create(name: 'Action') }

   # describe the CRUD operations
  describe "Check CRUD" do
    # Expect genre to be created
    it "genre can be created" do
      expect(genre).to be_valid
    end

    # Expect created genre to be able to read
    it "genre can be read" do
      expect(Genre.find(genre.id)).to eq(genre)
    end

    # Expect existing genre to be able to update
    it "updates a genre" do
      genre.update(name: "Horror")
      expect(Genre.find_by(name: "Horror")).to eq(genre)
    end

    # Expect existing genre to be able to delete
    it "deletes a genre" do
      genre.destroy
      expect(Genre.find_by(id: genre)).to be_nil
    end
  end
  # describe the validations
  describe "Check Validation" do
   # test if a genre is invalid when trying to create one with a non-unique name.
    it "invalid with non-unique name" do
      Genre.create(name:"Action")
      genre = Genre.new(name: "Action")
      genre.valid?
      expect(genre.errors[:name]).to include ("has already been taken")
    end
    # test if a genre is invalid when trying to create without a name.
    it "invalid without a name" do
      genre = Genre.new(name: nil)
      genre.valid?
      expect(genre.errors[:name]).to include("can't be blank")
    end
  end
   # describe the associations
   describe "Check Association" do
    it "has many movies" do
      association = described_class.reflect_on_association(:movies)
      expect(association.macro).to eq(:has_and_belongs_to_many)
    end
  end

  #check for search keyword
  describe '.search_by_name' do
    let!(:genre1) { Genre.create(name: 'Action') }
    let!(:genre2) { Genre.create(name: 'Comedy') }

    # Expect to return genre name that matched the keyword
    it 'returns genres whose name matches the keyword' do
      result = described_class.search_by_name('Action')
      expect(result).to include(genre1)
      expect(result).not_to include(genre2)
    end

    # Expect to return empty result of no genre matches the keyword
    it 'returns empty result if no genre matches the keyword' do
      result = described_class.search_by_name('Drama')
      expect(result).to be_empty
    end
  end

  #check genre does not have number
  describe "#name_does_not_contain_digits" do
    # Expect genre name not to include only digits
    it "is not valid and adds error when the name consists solely of digits" do
      genre = Genre.new(name: '12345')
      genre.valid?
      expect(genre.errors[:name]).to include("can't consist of only digits")
    end

    # Expect genre name to be valid when contains letters and digits
    it "is valid when the name contains letters and digits" do
      genre = Genre.new(name: 'action1')
      genre.valid?
      expect(genre.errors[:name]).to include("can't consist of only digits")
    end
  end
end
