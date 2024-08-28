const jwt = require('jsonwebtoken');
const bcrypt = require('bcrypt');

const User = require('../models/user');

exports.register = async (req, res, next) => {
  try {
    console.log(req.body);
    const { email, name, password } = req.body;
    const user = await User.create({
      email,
      name,
      password,
    });
    const token = jwt.sign({ email, name }, process.env.JWT_SECRET);

    res.status(201).json({
      status: 'success',
      token,
    });
  } catch (e) {
    console.log(e);
    res.status(400).json({
      status: 'fail',
      message: 'Email already exists',
    });
  }
};

exports.login = async (req, res, next) => {
  try {
    const { email, password } = req.body;
    const user = await User.findOne({ email }).select('+password');

    if (!user || !(await bcrypt.compare(password, user.password))) {
      return res.status(401).json({
        status: 'fail',
        message: 'Incorrect credentials',
      });
    }

    const name = user.name;
    const token = jwt.sign({ email, name }, process.env.JWT_SECRET);

    res.status(200).json({
      status: 'success',
      token,
    });
  } catch (e) {
    res.status(400).json({
      status: 'fail',
      message: 'Some error occured',
    });
  }
};

exports.verifyjwt = async (req, res, next) => {
  try {
    const { token } = req.body;
    if (!token) {
      return res.status(400).json({
        status: 'fail',
        message: 'No token',
      });
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    if (!(await User.findOne({ email: decoded.email }))) {
      return res.status(404).json({
        status: 'fail',
        message: 'User not found',
      });
    }

    res.status(200).json({
      status: 'success',
      token,
    });
  } catch (e) {
    console.log(e);
    res.status(400).json({
      status: 'fail',
      message: 'Signature mismatch',
    });
  }
};
