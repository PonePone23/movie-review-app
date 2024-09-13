# spec/models/year_spec.rb
require 'rails_helper'

RSpec.describe Year, type: :model do
  after(:each) do
    Movie.destroy_all
    Genre.destroy_all
    User.destroy_all
    Year.destroy_all
    # Add cleanup for other relevant models if needed
  end

  # Testing CRUD operation
  describe 'CRUD Operation' do
    let(:year){
      Year.create(year:2000)
    }
    # Expect to be able to create year
    it 'create year' do
      expect(year).to be_valid
    end

    # Expect to be able to read the created year
    it 'Year read' do
      expect(Year.find(year.id)).to eq(year)
    end

    # Expect to be able to update tje existing year
    it 'year update' do
      year.update(year: 2001)
      expect(Year.find_by_year(year.year)).to eq(year)
    end

    # Expect to be able to delete tge existing year
    it 'year delete' do
      year.destroy
      expect(Year.find_by(id: year.id)).to be_nil
    end
  end

  # Test cases for validation
  describe 'validation' do
    # Expect the year to have a unique year
    it 'Unique year' do
      existing_year = Year.create(year:2000)
      new_year = Year.new(year:2000)
      new_year.valid?
        expect(new_year.errors[:year]).to include("has already been taken")
    end
  end

  # Test cases for search
  describe '.search_by_year' do
    # Initial data setup
    let!(:year_2000) { Year.create(year: 2000) }
    let!(:year_2001) { Year.create( year: 2001) }
    let!(:year_2002) { Year.create( year: 2002) }

    context 'when searching for a matching year' do
      # Expect to return the year that matches the searched keyword
      it 'returns years with matching keyword' do
        result = described_class.search_by_year('2000')
        expect(result).to include(year_2000)
        expect(result).not_to include(year_2001, year_2002)
      end
    end

    context 'when no matching year is found' do
      # Expect to return empty result
      it 'returns an empty result set' do
        result = described_class.search_by_year('1999')
        expect(result).to be_empty
      end
    end
  end
end
