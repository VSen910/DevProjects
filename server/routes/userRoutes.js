const express = require('express');

const userController = require('../controllers/userController');

const userRouter = express.Router();

userRouter.patch('/follow', userController.followUser);
userRouter.patch('/', userController.updateUser);
userRouter.route('/:email').get(userController.getUser);
userRouter.route('/search/:searchString').get(userController.searchUser);

module.exports = userRouter;