import type { NextConfig } from 'next';

const nextConfig: NextConfig = {
  outputFileTracingRoot: '/var/home/admin/IdeaProjects/prostore-main',
  images: {
    remotePatterns: [
      {
        protocol: 'https',
        hostname: 'utfs.io',
        port: '',
      },
    ],
  },
};

export default nextConfig;
