const jwt = require('jsonwebtoken');

const User = require('../models/user');

exports.getUser = async (req, res, next) => {
  try {
    const email = req.params.email;
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(404).json({
        status: 'fail',
        message: 'User not found',
      });
    }

    res.status(200).json({
      status: 'success',
      user,
    });
  } catch (e) {
    res.status(400).json({
      status: 'fail',
      message: 'Bad request',
    });
  }
};

exports.updateUser = async (req, res, next) => {
  try {
    if (
      !req.headers.authorization ||
      !req.headers.authorization.startsWith('Bearer')
    ) {
      return res.status(401).json({
        status: 'fail',
        message: 'No token',
      });
    }

    const token = req.headers.authorization.trim().split(' ')[1];
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    const email = decoded.email;

    const user = await User.findOneAndUpdate({ email }, req.body, {
      new: true,
    });
    if (!user) {
      return res.status(401).json({
        status: 'fail',
        message: 'Invalid token',
      });
    }

    res.status(200).json({
      status: 'success',
      user,
    });
  } catch (e) {
    res.status(400).json({
      status: 'fail',
      message: 'Bad request',
    });
  }
};

exports.followUser = async (req, res, next) => {
  try {
    if (
      !req.headers.authorization ||
      !req.headers.authorization.startsWith('Bearer')
    ) {
      return res.status(400).json({
        status: 'fail',
        message: 'Invalid token',
      });
    }

    const token = req.headers.authorization.trim().split(' ')[1];
    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    const followingUserEmail = decoded.email;
    const followedUserEmail = req.body.email;

    const followingUser = await User.findOne({ email: followingUserEmail });
    const followedUser = await User.findOne({ email: followedUserEmail });

    const isFollowing = followingUser.following.includes(followedUserEmail);

    if (!isFollowing) {
      followingUser.following.push(followedUserEmail);
      followedUser.followers.push(followingUserEmail);
    } else {
      followingUser.following = followingUser.following.filter(
        (email) => email !== followedUserEmail
      );
      followedUser.followers = followedUser.followers.filter(
        (email) => email !== followingUserEmail
      );
    }

    await followingUser.save();
    await followedUser.save();

    res.status(200).json({
      status: 'success',
      followed: !isFollowing,
    });
  } catch (e) {
    console.log(e);
    res.status(400).json({
      status: 'fail',
      message: 'User not found',
    });
  }
};

exports.searchUser = async (req, res, next) => {
  try {
    if (
      !req.headers.authorization ||
      !req.headers.authorization.startsWith('Bearer')
    ) {
      return res.status(401).json({
        status: 'fail',
        message: 'No token',
      });
    }

    const token = req.headers.authorization.trim().split(' ')[1];
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    const email = decoded.email;

    const user = await User.findOne({ email });
    if (!user) {
      return res.status(401).json({
        status: 'fail',
        message: 'Invalid token',
      });
    }

    const searchString = req.params.searchString;
    const users = await User.find({
      $and: [
        { email: { $ne: email } },
        {
          $or: [
            { name: { $regex: `^${searchString}` } },
            { email: { $regex: `^${searchString}` } },
          ],
        },
      ],
    }).select('email name picturePath');

    res.status(200).json({
      status: 'success',
      users,
    });
  } catch (e) {
    console.log(e);
    res.status(400).json({
      status: 'fail',
      message: 'Bad request',
    });
  }
};
