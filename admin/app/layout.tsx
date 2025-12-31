import type { Metadata } from "next";
import "./globals.css";
import Toaster from "./components/Toaster";

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
        {children}
        <Toaster />
      </body>
    </html>
  );
}
