const jwt = require('jsonwebtoken');

const Post = require('../models/post');
const User = require('../models/user');

exports.getPost = async (req, res, next) => {
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

    const postId = req.params.id;
    const post = await Post.findById(postId).populate('postedBy');

    if (!post) {
      return res.status(404).json({
        status: 'fail',
        message: 'Post not found',
      });
    }

    res.status(200).json({
      status: 'success',
      post,
    });
  } catch (e) {
    console.log(e)
    res.status(400).json({
      status: 'fail',
      message: 'Bad request',
    });
  }
};

exports.createPost = async (req, res, next) => {
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

    console.log(req.body);
    const {
      title,
      github,
      deployedLink,
      description,
      screenshots,
      recordings,
    } = req.body;
    
    const postedBy = user._id;
    const post = await Post.create({
      email,
      postedBy,
      title,
      github,
      deployedLink,
      description,
      screenshots,
      recordings,
    });

    res.status(201).json({
      status: 'success',
      post,
    });
  } catch (e) {
    console.log(e);
    res.status(400).json({
      status: 'fail',
      message: 'Post not created',
    });
  }
};

exports.deletePost = async (req, res, next) => {
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

    if (!(await User.findOne({ email }))) {
      return res.status(401).json({
        status: 'fail',
        message: 'Invalid token',
      });
    }

    const id = req.params.id;
    const post = await Post.findByIdAndDelete(id);

    if (!post) {
      return res.status(404).json({
        status: 'fail',
        message: 'Post not found',
      });
    }

    res.status(204).json({
      status: 'success',
    });
  } catch (e) {
    console.log(e)
    res.status(400).json({
      status: 'fail',
      message: 'Bad request',
    });
  }
};

exports.getPostsByEmail = async (req, res, next) => {
  try {
    const email = req.query.email;
    const posts = await Post.find({ email }).select('title description');

    if (!posts) {
      res.status(404).json({
        status: 'fail',
        message: 'No posts found',
      });
    }

    res.status(200).json({
      status: 'success',
      posts,
    });
  } catch (e) {
    console.log(e)
    res.status(400).json({
      status: 'fail',
      message: 'Bad request',
    });
  }
};

exports.getFeed = async (req, res, next) => {
  console.log('start');
  try {
    if (
      !req.headers.authorization ||
      !req.headers.authorization.startsWith('Bearer')
    ) {
      return res.status(401).json({
        status: 'fail',
        message: 'No token hahah',
      });
    }

    const token = req.headers.authorization.trim().split(' ')[1];
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    const email = decoded.email;

    console.log('email');

    const user = await User.findOne({ email });
    if (!user) {
      return res.status(401).json({
        status: 'fail',
        message: 'Invalid token',
      });
    }

    const following = user.following;
    console.log(following);
    const posts = await Post.find({ email: { $in: following } })
      .populate('postedBy')
      .select('_id title')
      .sort({
        createdAt: -1,
      });

    console.log('here');
    if (!posts) {
      return res.status(404).json({
        status: 'fail',
        message: 'No posts found',
      });
    }

    const feed = posts.map((post) => ({
      _id: post._id,
      title: post.title,
      name: post.postedBy.name,
      picturePath: post.postedBy.picturePath,
    }));

    res.status(200).json({
      status: 'success',
      feed,
    });
  } catch (e) {
    console.log(e);
    res.status(400).json({
      status: 'fail',
      message: 'Bad request hahaha',
      error: e,
    });
  }
};

exports.likePost = async (req, res, next) => {
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

    const postId = req.body.postId;
    const post = await Post.findById(postId);

    if (!post) {
      return res.status(404).json({
        status: 'fail',
        message: 'Post not found',
      });
    }

    const isLiked = post.likedBy.includes(user.email);

    if (isLiked) {
      post.likedBy = post.likedBy.filter((email) => email !== user.email);
    } else {
      post.likedBy.push(user.email);
    }

    await post.save();

    res.status(200).json({
      status: 'success',
      isLiked: !isLiked,
    });
  } catch (e) {
    console.log(e)
    res.status(400).json({
      status: 'fail',
      message: 'Bad request',
    });
  }
};

exports.addComment = async (req, res, next) => {
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

    const comment = {
      id: Date.now().toString(36) + Math.random().toString(36).substr(2),
      email: user.email,
      name: user.name,
      picturePath: user.picturePath,
      comment: req.body.comment,
    };

    const postId = req.body.postId;
    const post = await Post.findByIdAndUpdate(postId, {
      $push: { comments: comment },
    });

    res.status(201).json({
      status: 'success',
      comment,
    });
  } catch (e) {
    res.status(404).json({
      status: 'fail',
      message: 'Post not found',
    });
  }
};

exports.deleteComment = async (req, res, next) => {
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

    const postId = req.body.postId;
    const post = await Post.findByIdAndUpdate(postId, {
      $pull: { comments: { id: req.body.commentId } },
    });

    res.status(204).json({
      status: 'success',
    });
  } catch (e) {
    console.log(e);
    res.status(404).json({
      status: 'fail',
      message: 'Post not found',
    });
  }
};
