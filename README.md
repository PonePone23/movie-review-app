# README

Project Name 
MTM Movies

Project Desription
  This project is about the development of a dynamic movie review website
using the Ruby on Rails framework with MySQL. The website is created with the aim
of providing a fun and engaging platform for movie lovers to share, explore and discuss their favorite movies.
  The main objective of the project is to offer an easy-to-use platform that
allows users to give reviews, engage with the community, and discover diverse movie
perspectives.

Installation
1. Environment Setup
Ensure that you have Ruby and Rails installed on your system.
If not, follow the installation instructions for your operating system from the official Ruby and Rails documentation.

Also, ensure that you have Git and MySQL installed in your system.

2. Cloning Repository
Clone the project repository from the GitHub repository using the following command:
git clone https://github.com/mtm-intern/movie-review

3. Dependencies Installation
  Navigate to the project directory.
    cd movie-review

  Install the project dependencies using Bundler.
    bundle install

4. Database Setup
  Configure your database settings in the config/database.yml.
  Create the development and test databases using
    rails db:create

5. Database Migration
  Run migrations to create the necessary database tables
    rails db:migrate

6. Starting the Server
  Start the Rails server using the following command
    rails server or rails s

    The application will be accessible at http://localhost:3000 on your web browser.