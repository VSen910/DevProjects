
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

## Screenshots

<img src=https://github.com/user-attachments/assets/b9df04ee-0b43-47cb-a513-9aee9d34e689 width=200px/>
<img src=https://github.com/user-attachments/assets/4b5fb234-0b0c-4f89-8b9b-e6c6cb113391 width=200px/>
<img src=https://github.com/user-attachments/assets/d6627dbb-0659-4ea3-b540-0149b7ae85a5 width=200px/>
<img src=https://github.com/user-attachments/assets/5b3291d0-7a8c-4f9c-9d3a-324cea80cdd2 width=200px/>
<img src=https://github.com/user-attachments/assets/fd964f48-afa6-4df4-ac1d-596d2c332d7c width=200px/>
<img src=https://github.com/user-attachments/assets/c34decc7-54da-4a2a-be88-d6056e6e4d36 width=200px/>
<img src=https://github.com/user-attachments/assets/472af951-4a77-4938-af53-7774a19ff259 width=200px/>
