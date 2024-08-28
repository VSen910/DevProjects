const express = require('express');

const postController = require('../controllers/postController');

const postRouter = express.Router();

postRouter
  .route('/')
  .post(postController.createPost)
  .get(postController.getPostsByEmail);
postRouter
  .route('/:id')
  .delete(postController.deletePost)
  .get(postController.getPost);
postRouter.route('/more/feed').get(postController.getFeed);
postRouter.route('/more/like').patch(postController.likePost);
// postRouter.route('/unlike').patch(postController.unlikePost);
postRouter.route('/more/comment').patch(postController.addComment);
postRouter.route('/more/uncomment').patch(postController.deleteComment);

module.exports = postRouter;
