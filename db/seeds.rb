## db/seeds.rb
#require 'faker'
#
## Generate movie poster image URLs using LoremFlickr
#def generate_movie_poster_url
#  "https://loremflickr.com/300/400/movie"
#end
#
## Seed 20 movies using Faker data
#20.times do
#  movie = Movie.new(
#    name: Faker::Movie.title,
#    review: Faker::Lorem.paragraph,
#    casts: Faker::Name.name,
#    release_date: Faker::Date.between(from: 10.years.ago, to: Date.today),
#    country: Faker::Address.country,
#    production: Faker::Company.name,
#    director: Faker::Name.name,
#    duration: "#{Faker::Number.number(digits: 2)} min",
#    trailer_url: Faker::Internet.url,
#    user_id: 1,
#    rating: Faker::Number.between(from: 1, to: 5),
#    genre_ids: (1..25).to_a.sample(3) # Example: Select 3 random genre ids from 1 to 25
#  )
#
#  # Attach image to the movie
#  image_url = generate_movie_poster_url
#  movie.image.attach(io: URI.open(image_url), filename: "#{movie.name.parameterize}.jpg")
#
#  if movie.save
#    puts "Created movie: #{movie.name}"
#  else
#    puts "Failed to create movie: #{movie.errors.full_messages.join(', ')}"
#  end
#end
#
