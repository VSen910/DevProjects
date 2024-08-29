
# DevProjects

DevProjects is a social platform for developers where they can share about their projects in a comprehensive manner. This way, they can gain recognition for their work also allowing other developers to find inspiration for their own project ideas.


## Installation

Navigate to the server folder and create a `config.env` file and place your MongoDB credentials along with the port and JWT secret as follows:
```bash
PORT=***
DATABASE=***
DATABASE_PASSWORD=***
JWT_SECRET=***
```
Note that the password string in `DATABASE` has to be replaced with `<PASSWORD>`.

Install dependencies for the server:

```bash
npm install
```
Navigate back to the root folder, and create a `.env` file and place your Cloudinary cloud name and upload preset along with the host URL as follows:
```bash
CLOUDINARY_CLOUD_NAME=***
CLOUDINARY_UPLOAD_PRESET=***
HOST=***
```

Install the dependencies for the flutter project:
```bash
flutter pub get
```
Go back to server folder and start the server:
```bash
npm start
```
Finally run the flutter app.

## Features

- Create and delete posts with mandatory Github links
- Upload relevant screenshots and recordings
- Likes and comments on posts
- Follow and unfollow users
- Search for users
- Feed with posts from followed users
- Edit your profile

