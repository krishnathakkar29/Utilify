import { createSupabaseClient } from "./client";
import { v4 as uuidv4 } from "uuid";

type UploadProps = {
  file: File;
  bucket: string;
  folder: string;
};

function getStorage() {
  const { storage } = createSupabaseClient();
  return storage;
}

export async function uploadFile({ file, bucket, folder }: UploadProps) {
  const fileName = file.name;
  const fileExtension = fileName.slice(fileName.lastIndexOf(".") + 1);
  const path = `${folder ? folder + "/" : ""}${uuidv4()}.${fileExtension}`;
  const bucketName = bucket && bucket.trim() ? bucket : "email-resume";
  try {
    const storage = getStorage();
    const { data, error } = await storage.from(bucketName).upload(path, file);

    if (error) {
      return { imageUrl: "", error: "Image upload failed" };
    }

    const imageUrl = `${process.env
      .NEXT_PUBLIC_SUPABASE_URL!}/storage/v1/object/public/email-resume/${
      data?.path
    }`;
    return { imageUrl, error: "" };
  } catch (error) {
    console.log(error);
    return { imageUrl: "", error: "Failed to compress image" };
  }
}

export async function downloadFile() {
  const storage = getStorage();
  try {
    const { data, error } = await storage
      .from("email-resume")
      .download("attachments/0a1ec39a-9cdf-48c2-b495-80fc6380db54.pdf");

    if (error) {
      return { data: null, error: "File download failed" };
    }

    // Convert Blob to Buffer if needed
    if (data instanceof Blob) {
      const arrayBuffer = await data.arrayBuffer();
      const buffer = Buffer.from(arrayBuffer);
      return { data: buffer, error: null };
    }

    return { data, error: null };
  } catch (error) {
    console.error("Download error:", error);
    return { data: null, error: "Failed to download file" };
  }
}

export const deleteImage = async (imageUrl: string) => {
  const bucketAndPathString = imageUrl.split("/storage/v1/object/public/")[1];
  const firstSlashIndex = bucketAndPathString.indexOf("/");

  const bucket = bucketAndPathString.slice(0, firstSlashIndex);
  const path = bucketAndPathString.slice(firstSlashIndex + 1);

  const storage = getStorage();

  const { data, error } = await storage.from(bucket).remove([path]);

  return { data, error };
};
