const express = require('express');
const morgan = require('morgan');

const authRouter = require('./routes/authRoutes');
const userRouter = require('./routes/userRoutes');
const postRouter = require('./routes/postRoutes');

const app = express();

app.use(express.json());
app.use(morgan('tiny'));

app.use('/', authRouter);
app.use('/users', userRouter);
app.use('/posts', postRouter);

module.exports = app;
