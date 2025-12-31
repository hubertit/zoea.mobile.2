import type { Metadata } from "next";
import "./globals.css";
import Toaster from "./components/Toaster";
import HealthCheckProvider from "./components/HealthCheckProvider";

export const metadata: Metadata = {
  title: "Zoea Admin Portal",
  description: "Admin portal for managing Zoea platform",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body>
        <HealthCheckProvider>
          {children}
        </HealthCheckProvider>
        <Toaster />
      </body>
    </html>
  );
}
