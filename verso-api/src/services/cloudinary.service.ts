import { v2 as cloudinary } from 'cloudinary';

cloudinary.config({
  cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
  api_key: process.env.CLOUDINARY_API_KEY,
  api_secret: process.env.CLOUDINARY_API_SECRET,
});

export async function uploadImage(
  file: Express.Multer.File,
  folder: string = 'images'
): Promise<string> {
  const result = await new Promise<string>((resolve, reject) => {
    cloudinary.uploader.upload(
      file.path,
      {
        resource_type: 'image',
        folder,
        transformation: [
          { width: 500, height: 500, crop: 'fill', gravity: 'face' },
        ],
      },
      (error, result) => {
        if (error) reject(error);
        else resolve(result!.secure_url);
      }
    );
  });

  return result;
}

export async function uploadAudio(file: Express.Multer.File): Promise<string> {
  const result = await new Promise<string>((resolve, reject) => {
    cloudinary.uploader.upload(
      file.path,
      {
        resource_type: 'video',
        folder: 'recitations',
        format: 'mp3',
      },
      (error, result) => {
        if (error) reject(error);
        else resolve(result!.secure_url);
      }
    );
  });

  return result;
}
