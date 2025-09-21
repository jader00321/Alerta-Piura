const cloudinary = require('cloudinary').v2;
const { CloudinaryStorage } = require('multer-storage-cloudinary');
const multer = require('multer');
require('dotenv').config();

// Configure Cloudinary with your credentials
cloudinary.config({
  cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
  api_key: process.env.CLOUDINARY_API_KEY,
  api_secret: process.env.CLOUDINARY_API_SECRET
});

// Configure Multer to use Cloudinary for storage
const storage = new CloudinaryStorage({
  cloudinary: cloudinary,
  params: {
    folder: 'alerta_piura', // The folder name in your Cloudinary account
    allowed_formats: ['jpg', 'png', 'jpeg'],
    transformation: [{ width: 800, height: 800, crop: 'limit' }] // Resize images to a max of 800x800
  },
});

const upload = multer({ storage: storage });

module.exports = upload;