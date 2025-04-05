import { BACKEND_FLASK_URL } from "@/config/config";
import axios from "axios";

// Create axios instance with default config
const api = axios.create({
  baseURL: "https://modular-sold-refused-namibia.trycloudflare.com",
  headers: {
    "Content-Type": "multipart/form-data",
  },
});

// Set JSON content type for regular API requests
const jsonAPI = axios.create({
  baseURL: "https://modular-sold-refused-namibia.trycloudflare.com",
  headers: {
    "Content-Type": "application/json",
  },
});

// PDF manipulation endpoints
export const pdfAPI = {
  merge: (files: File[]) => {
    const formData = new FormData();
    files.forEach((file) => {
      formData.append("files", file);
    });
    return api.post("/merge", formData, { responseType: "blob" });
  },

  split: (file: File, startPage: number, endPage: number) => {
    const formData = new FormData();
    formData.append("file", file);
    formData.append("start_page", String(startPage));
    formData.append("end_page", String(endPage));
    return api.post("/split", formData, { responseType: "blob" });
  },

  rotate: (file: File, angle: number) => {
    const formData = new FormData();
    formData.append("file", file);
    formData.append("angle", String(angle));
    return api.post("/rotate", formData, { responseType: "blob" });
  },
};

// Network utility endpoints
export const networkAPI = {
  ping: (host: string) => {
    return jsonAPI.post("/ping", {
      host,
    });
  },

  dnsLookup: (domain: string) => {
    console.log(domain);
    return jsonAPI.post("/dns-lookup", {
      host: domain,
    });
  },

  ipLookup: (domain: string) => {
    return jsonAPI.post("/ip-lookup", {
      host: domain,
    });
  },

  traceroute: (host: string) => {
    return jsonAPI.post("/traceroute", {
      host,
    });
  },
};

export default api;
