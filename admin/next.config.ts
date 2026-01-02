import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  /* config options here */
  output: 'standalone',
  // Disable image optimization for Docker
  images: {
    unoptimized: true,
  },
};

export default nextConfig;
