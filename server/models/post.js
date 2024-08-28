const mongoose = require('mongoose');

const postSchema = mongoose.Schema(
  {
    email: {
      type: String,
      required: true,
    },
    postedBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
    },
    title: {
      type: String,
      required: true,
    },
    github: {
      type: String,
      required: true,
    },
    deployedLink: {
      type: String,
      default: '',
    },
    description: {
      type: String,
      default: '',
    },
    screenshots: {
      type: Array,
      default: [],
    },
    recordings: {
      type: Array,
      default: [],
    },
    likedBy: {
      type: Array,
      default: [],
    },
    comments: {
      type: Array,
      default: [],
    },
  },
  { timestamps: true }
);

const Post = mongoose.model('Post', postSchema);

module.exports = Post;
